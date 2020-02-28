"""
Check all http/https links in files on 400 >= status code.
Exit with code if at least one link is broken. Exit with code 0 otherwise
"""
from urllib.error import HTTPError

from concurrent.futures.thread import ThreadPoolExecutor
from concurrent.futures import as_completed
import os

import argparse
import logging
import re
import urllib.request
from typing import Generator
from typing import List

LINK_PATTERN = "(?P<url>https?://[^\s]+)"

logger = logging.getLogger(__name__)


def configure_root_logger(verbose: bool):
    if verbose:
        log_level = logging.DEBUG
    else:
        log_level = logging.WARNING

    logging.basicConfig(level=log_level, format='%(asctime)s - %(levelname)s - %(message)s')


def configure_arg_parser() -> argparse.ArgumentParser:

    parser = argparse.ArgumentParser("Broken links crawler")

    parser.add_argument('directory', help='root directory where files to search broken links are located')
    parser.add_argument('ext', help='extensions of files which should be checked on broken links', nargs='+')
    parser.add_argument('--verbose', '-v', action='store_true', help='verbose log output')
    parser.add_argument('--pool', '-p', help='count of workers to make requests', type=int, default=10)

    return parser


class Config:

    def __init__(self, args: argparse.Namespace):
        """
        Config of script
        :param args: parsed command line arguments
        """

        self.verbose: bool = args.verbose
        self.directory: str = args.directory
        self.extensions: List[str] = args.ext
        self.pool_size: int = args.pool


def yield_files(directory: str, extensions: List[str]) -> Generator[str, None, None]:
    for dir_, _, files in os.walk(directory):
        for name in files:
            if any([name.endswith(ext) for ext in extensions]):
                yield os.path.join(dir_, name)


def yield_links(directory: str, extensions: List[str]) -> Generator[str, None, None]:
    for filepath in yield_files(directory, extensions):
        with open(filepath, 'r') as f:
            links = re.findall(LINK_PATTERN, f.read())
            for link in links:
                yield link


# Retrieve a single page and report the URL and contents
def load_link(link):
    with urllib.request.urlopen(link, timeout=10) as conn:
        return conn.status


def get_broken_links(pool_size: int, links: List[str]):
    """
    Make concurrent queries to links and collect those ones who has status code >=400
    :param pool_size: count of workers
    :param links: links to check
    :return:
    """
    broken_links = []
    with ThreadPoolExecutor(max_workers=pool_size) as executor:
        # Start the load operations and mark each future with its URL
        future_to_link = {executor.submit(load_link, link): link for link in links}
        for future in as_completed(future_to_link):
            link = future_to_link[future]
            try:
                status = future.result()
            except HTTPError as exc:
                broken_links.append(link)
                logger.error(f'BROKEN: Link {link} return {exc.code} status code')
            except Exception as exc:
                logger.error('EXCEPTION: %r generated an exception: %s' % (link, exc))
            else:
                if status >= 400:
                    logger.error(f'BROKEN: Link {link} return {status} status code')
                    broken_links.append(link)
                else:
                    logger.info(f'OK: Link {link} return {status} status code')
    return broken_links


def work(config: Config):
    """
    Looks for broken links and
    :param config:
    :return:
    """
    links = []
    for link in yield_links(config.directory, config.extensions):
        links.append(link)

    logger.info(f'Found {len(links)} links')

    broken_links = get_broken_links(config.pool_size, links)

    broken_links_sorted = sorted(list(
        set(broken_links)
    ))

    if broken_links:
        broken_links_str = '\n'.join(broken_links_sorted)
        print(f'There are broken links!.\nNext links are broken:\n{broken_links_str}')
        exit(1)


if __name__ == '__main__':

    arg_parser = configure_arg_parser()
    config_ = Config(
        arg_parser.parse_args()
    )
    configure_root_logger(config_.verbose)
    work(config_)



