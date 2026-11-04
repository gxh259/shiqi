#!/usr/bin/env python3
import pathlib,subprocess,tempfile
root=pathlib.Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='shiqi-tests-') as temp:
 exe=pathlib.Path(temp)/'tests'
 subprocess.run(['swiftc',str(root/'Sources/UpdateModels.swift'),str(root/'Tests/main.swift'),'-o',str(exe),'-module-cache-path',temp+'/cache'],check=True)
 subprocess.run([str(exe)],check=True)
