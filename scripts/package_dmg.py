#!/usr/bin/env python3
import argparse,pathlib,subprocess,tempfile,shutil,hashlib
p=argparse.ArgumentParser();p.add_argument('app',type=pathlib.Path);p.add_argument('output',type=pathlib.Path);a=p.parse_args();a.output=a.output.resolve();a.output.parent.mkdir(parents=True,exist_ok=True)
root=pathlib.Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='shiqi-dmg-') as temp:
 staging=pathlib.Path(temp);shutil.copytree(a.app,staging/'诗栖.app',copy_function=shutil.copy);(staging/'Applications').symlink_to('/Applications');shutil.copy(root/'INSTALL.md',staging/'安装说明.md')
 subprocess.run(['hdiutil','create','-ov','-volname','诗栖','-srcfolder',str(staging),'-format','UDZO',str(a.output)],check=True)
 subprocess.run(['hdiutil','verify',str(a.output)],check=True)
checksum=hashlib.sha256(a.output.read_bytes()).hexdigest();a.output.with_suffix('.dmg.sha256').write_text(checksum+'  '+a.output.name+'\n');print(checksum)
