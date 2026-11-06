#!/usr/bin/env python3
import pathlib,subprocess,tempfile
root=pathlib.Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='shiqi-tests-') as temp:
 exe=pathlib.Path(temp)/'tests'
 subprocess.run(['swiftc',str(root/'Sources/UpdateModels.swift'),str(root/'Sources/RestCountdown.swift'),str(root/'Tests/main.swift'),'-o',str(exe),'-module-cache-path',temp+'/cache'],check=True)
 subprocess.run([str(exe)],check=True)

with tempfile.TemporaryDirectory(prefix="shiqi-corpus-tests-") as temp:
 exe=pathlib.Path(temp)/"migration"
 subprocess.run(["swiftc",str(root/"Tests/CorpusMigration.swift"),"-o",str(exe),"-module-cache-path",temp+"/cache"],check=True)
 subprocess.run([str(exe),str(root/"Resources/index.html")],check=True)

with tempfile.TemporaryDirectory(prefix="shiqi-update-runner-tests-") as temp:
 exe=pathlib.Path(temp)/"runner-tests"
 subprocess.run(["swiftc",str(root/"Sources/UpdateModels.swift"),str(root/"Sources/UpdateProcessRunner.swift"),str(root/"Tests/UpdateRunnerTests.swift"),"-o",str(exe),"-module-cache-path",temp+"/cache"],check=True)
 subprocess.run([str(exe)],check=True)

with tempfile.TemporaryDirectory(prefix="shiqi-placement-tests-") as temp:
 exe=pathlib.Path(temp)/"placement-tests"
 subprocess.run(["swiftc",str(root/"Sources/PoemPlacement.swift"),str(root/"Tests/PoemPlacementTests.swift"),"-o",str(exe),"-module-cache-path",temp+"/cache","-framework","Cocoa"],check=True)
 subprocess.run([str(exe)],check=True)

with tempfile.TemporaryDirectory(prefix="shiqi-typography-tests-") as temp:
 exe=pathlib.Path(temp)/"typography-tests"
 color=pathlib.Path(temp)/"Color.swift"
 source=(root/"Sources/Resources.swift").read_text()
 color.write_text("import Cocoa\n"+source[source.index("extension NSColor {"):])
 subprocess.run(["swiftc",str(root/"Sources/PoetryStyle.swift"),str(root/"Sources/PoemPlacement.swift"),str(color),str(root/"Tests/TypographyTests.swift"),"-o",str(exe),"-module-cache-path",temp+"/cache","-framework","Cocoa","-framework","CoreText"],check=True)
 subprocess.run([str(exe)],check=True)

with tempfile.TemporaryDirectory(prefix="shiqi-schedule-tests-") as temp:
 exe=pathlib.Path(temp)/"schedule-tests"
 subprocess.run(["swiftc",str(root/"Sources/WallpaperSchedule.swift"),str(root/"Tests/WallpaperScheduleTests.swift"),"-o",str(exe),"-module-cache-path",temp+"/cache"],check=True)
 subprocess.run([str(exe)],check=True)

with tempfile.TemporaryDirectory(prefix="shiqi-session-tests-") as temp:
 exe=pathlib.Path(temp)/"session-tests"
 subprocess.run(["swiftc",str(root/"Sources/WallpaperSchedule.swift"),str(root/"Sources/NativeSchedule.swift"),str(root/"Sources/SessionActivity.swift"),str(root/"Tests/SessionActivityTests.swift"),"-o",str(exe),"-module-cache-path",temp+"/cache","-framework","Cocoa"],check=True)
 subprocess.run([str(exe)],check=True)
