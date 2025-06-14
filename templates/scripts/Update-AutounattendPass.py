import os
import sys
import base64
import logging
import xml.etree.ElementTree as ET

LOG_LEVEL = logging.ERROR
UNATTEND_URN = 'urn:schemas-microsoft-com:unattend'
CPI_URN = 'urn:schemas-microsoft-com:cpi'
ADMINISTRATOR_PASSWORD_XPATH = f'.//{{{UNATTEND_URN}}}AdministratorPassword/{{{UNATTEND_URN}}}Value'
AUTOLOGON_PASSWORD_XPATH = f'.//{{{UNATTEND_URN}}}AutoLogon[{{{UNATTEND_URN}}}Username=\'Administrator\']/{{{UNATTEND_URN}}}Password/{{{UNATTEND_URN}}}Value'

logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(LOG_LEVEL)
logger.addHandler(handler)

if len(sys.argv) != 3:
	logger.error('[!] Usage: python3 Update-AutounattendPass.py [ORIGINAL FILEPATH] [NEW FILEPATH]')
	sys.exit(1)

SSH_PASSWORD = os.environ.get("PKR_VAR_SSH_PASSWORD")
if SSH_PASSWORD == None:
	logger.error('[!] PKR_VAR_SSH_PASSWORD environment variable not set')
	sys.exit(1)

infile = sys.argv[1]
outfile = sys.argv[2]

try:
	logger.info(f'[*] Reading file {infile}...')
	tree = ET.parse(infile)
except FileNotFoundError:
	logger.error(f'[!] File {infile} does not exist')
	sys.exit(1)
except Exception as e:
	logger.error(f'[!] Failed to parse input file as XML: {str(e)}')
	sys.exit(1)

root = tree.getroot()
ET.register_namespace('', UNATTEND_URN)
ET.register_namespace('cpi', CPI_URN)

nodes = root.findall(ADMINISTRATOR_PASSWORD_XPATH)
if len(nodes) != 1:
	logger.error(f'[!] {len(nodes)} AdministratorPassword nodes returned, expected 1')
	sys.exit(1)
else:
	nodes[0].text = base64.b64encode(f'{SSH_PASSWORD}AdministratorPassword'.encode('UTF-16LE')).decode()

nodes = root.findall(AUTOLOGON_PASSWORD_XPATH)
if len(nodes) != 1:
        logger.error(f'[!] {len(nodes)} Administrator AutoLogon nodes returned, expected 1')
        sys.exit(1)
else:
	nodes[0].text = base64.b64encode(f'{SSH_PASSWORD}Password'.encode('UTF-16LE')).decode()

try:
	logger.info(f'[*] Writing updated XML file {outfile}...')
	tree.write(outfile, encoding='utf-8', xml_declaration=True)
except Exception as e:
	logger.error(f'[!] Failed to write XML output file: {str(e)}')
	sys.exit(1)
