#!/usr/bin/env python3
import argparse
import json
import sys
import requests

from helpers.config import Config
from transfer.analysis import sync_analysis_data
from transfer.asset import transfer_asset, get_src_asset_details, create_asset
from transfer.media import get_media, del_media
from transfer.xml import (
    get_src_submissions_xml,
    get_submission_edit_data,
    print_stats,
    transfer_submissions,
)
from transfer.validation_status import sync_validation_statuses

# Lista de UUIDs a transferir (ajusta según tus necesidades)
my_uuids_to_transfer = ['60e4ace2-31b9-4f19-bb4e-074d56494c29', '0b45e9ae-518b-40c2-8f4c-ba5224a20483', 'd9257969-a1f7-493f-b4a0-1f66f8eebda2']

def get_uuids(config_loc, params):
    # Esta función simplemente devuelve la lista de UUIDs hardcodeada
    return my_uuids_to_transfer

def chunker(seq, size):
    # Divide una secuencia en trozos de tamaño 'size'
    for i in range(0, len(seq), size):
        yield seq[i : i + size]

def get_params(uuids=[], limit=10000, fields=[]):
    # Construye un diccionario con parámetros para la consulta API
    query = json.dumps({"_uuid": {"$in": uuids}})
    return {
        'format': 'json',
        'limit': limit,
        'fields': json.dumps(fields),
        'query': query
    }

def main(
    limit,
    asset=False,
    src_asset_uid=None,
    last_failed=False,
    keep_media=False,
    regenerate=False,
    quiet=False,
    validate=True,
    sync=False,
    validation_statuses=False,
    analysis_data=False,
    chunk_size=100,
    config_file=None,
    skip_media=False,
):
    if src_asset_uid:
        validate = False

    config = Config(config_file=config_file, validate=validate, asset=asset)

    if src_asset_uid:
        config.update_config(loc='src', new_data={'asset_uid': src_asset_uid})

    if asset:
        print('📋 Transferring asset, versions and form media')
        asset_setup_content, *_ = get_src_asset_details(config_src=config.src)
        asset_uid = create_asset(config.dest, asset_setup_content)
        print(f'✨ New asset UID at `dest`: {asset_uid}')
        config.update_config(loc='dest', new_data={'asset_uid': asset_uid})
        transfer_asset(config)

    if validation_statuses and not sync:
        print('✏️ Syncing validation statuses')
        sync_validation_statuses(config, chunk_size, limit)
        sys.exit()

    if analysis_data and not sync:
        print('📶 Syncing analysis data')
        sync_analysis_data(config, limit)
        sys.exit()

    config_src = config.src
    all_results = []
    submission_edit_data = get_submission_edit_data()

    def transfer(all_results, url=None):
        parsed_xml = get_src_submissions_xml(xml_url=url)
        submissions = parsed_xml.findall(f'results/')
        next_ = parsed_xml.find('next').text
        results = transfer_submissions(
            submissions,
            submission_edit_data,
            quiet=quiet,
            regenerate=regenerate,
        )
        all_results += results

        if next_ != 'None' and next_ is not None:
            transfer(all_results, next_)

    # Usa los UUIDs hardcodeados para filtrar
    uuids = my_uuids_to_transfer
    xml_url_src = config_src['xml_url'] + f'?limit={limit}&query={json.dumps({"_uuid": {"$in": uuids}})}'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='A CLI tool to transfer submissions between projects with identical XLSForms.'
    )
    parser.add_argument(
        '--limit',
        '-l',
        default=5000,
        type=int,
        help='Number of submissions included in each batch for download and upload.',
    )
    parser.add_argument(
        '--asset',
        '-a',
        default=False,
        action='store_true',
        help='Transfer asset, versions and form media.',
    )
    parser.add_argument(
        '--src-asset-uid',
        '-sau',
        default=None,
        type=str,
        help='Override asset_uid value in config file.',
    )
    parser.add_argument(
        '--last-failed',
        '-lf',
        default=False,
        action='store_true',
        help='Run transfer again with only last failed submissions.',
    )
    parser.add_argument(
        '--config-file',
        '-c',
        default='config.json',
        type=str,
        help='Location of config file.',
    )
    parser.add_argument(
        '--regenerate-uuids',
        '-R',
        default=False,
        action='store_true',
        help='Regenerate submission UUIDs.',
    )
    parser.add_argument(
        '--no-validate',
        '-N',
        default=False,
        action='store_true',
        help='Skip validation of config file.',
    )
    parser.add_argument(
        '--keep-media',
        '-k',
        default=False,
        action='store_true',
        help='Keep submission attachments rather than cleaning up after transfer.',
    )
    parser.add_argument(
        '--sync',
        '-s',
        default=False,
        action='store_true',
        help='Sync src and dest project data',
    )
    parser.add_argument(
        '--validation-statuses',
        '-vs',
        default=False,
        action='store_true',
        help='Sync src and dest validation statuses',
    )
    parser.add_argument(
        '--analysis-data',
        '-ad',
        default=False,
        action='store_true',
        help='Sync src and dest analysis data (transcript, translations, analysis questions)',
    )
    parser.add_argument(
        '--chunk-size',
        '-cs',
        default=20,
        type=int,
        help='Number of submissions included in each batch for sync query filters.',
    )
    parser.add_argument(
        '--skip-media',
        '-sm',
        default=False,
        action='store_true',
        help='Skip media downloads',
    )
    
    parser.add_argument(
        '--quiet',
        '-q',
        default=False,
        action='store_true',
        help='Suppress stdout',
    )


    args = parser.parse_args()


    try:
        main(
            limit=args.limit,
            asset=args.asset,
            src_asset_uid=args.src_asset_uid,
            last_failed=False,  # Set to False
            regenerate=args.regenerate_uuids,
            keep_media=args.keep_media,
            quiet=args.quiet,
            validate=not args.no_validate,
            sync=False,  # Set to False
            validation_statuses=args.validation_statuses,
            analysis_data=args.analysis_data,
            chunk_size=args.chunk_size,
            config_file=args.config_file,
            skip_media=args.skip_media,
        )
    except KeyboardInterrupt:
        print(' Stopping run')
        # Do something here so we can pick up again where this leaves off
        sys.exit()
