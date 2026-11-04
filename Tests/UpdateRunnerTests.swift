import Foundation
@main struct UpdateRunnerChecks {
 static func main()async throws{
  let runner=UpdateProcessRunner();var checks:[String]=[]
  try await runner.run("/usr/bin/true",[]);checks.append("successful subprocess")
  do{try await runner.run("/usr/bin/false",[]);fatalError("failure not propagated")}catch{checks.append("subprocess failure propagated")}
  let began=Date();do{try await runner.run("/bin/sleep",["5"],timeout:0.15);fatalError("timeout not enforced")}catch{assert(Date().timeIntervalSince(began)<2);checks.append("copy-process timeout bounded")}
  let task=Task{try await runner.run("/bin/sleep",["5"])};try await Task.sleep(nanoseconds:100_000_000);runner.cancel();do{try await task.value;fatalError("cancel not propagated")}catch{checks.append("active process cancellation")}
  let root=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString);defer{try? FileManager.default.removeItem(at:root)};let source=root.appendingPathComponent("poetry source");let target=root.appendingPathComponent("poetry target");try FileManager.default.createDirectory(at:source,withIntermediateDirectories:true);try Data("poetry".utf8).write(to:source.appendingPathComponent("诗词.txt"));try await runner.run("/usr/bin/ditto",[source.path,target.path]);let copied=try Data(contentsOf:target.appendingPathComponent("诗词.txt"));assert(copied==Data("poetry".utf8));checks.append("background ditto copy with spaces and Unicode")
  print(String(data:try JSONSerialization.data(withJSONObject:["success":true,"checks":checks],options:.prettyPrinted),encoding:.utf8)!)
 }
}
