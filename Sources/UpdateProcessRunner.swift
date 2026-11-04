import Foundation
final class UpdateProcessRunner:@unchecked Sendable {
 private let lock=NSLock();private var active:Process?
 func cancel(){lock.lock();let process=active;lock.unlock();if let process=process,process.isRunning{process.terminate()}}
 func run(_ executable:String,_ arguments:[String],timeout:TimeInterval=90)async throws {
  try await withCheckedThrowingContinuation{continuation in
   DispatchQueue.global(qos:.utility).async {
    do{try self.execute(executable,arguments,timeout:timeout);continuation.resume()}catch{continuation.resume(throwing:error)}
   }
  }
 }
 private func execute(_ executable:String,_ arguments:[String],timeout:TimeInterval)throws{
  let process=Process();process.executableURL=URL(fileURLWithPath:executable);process.arguments=arguments;process.standardOutput=FileHandle.nullDevice;process.standardError=FileHandle.nullDevice
  lock.lock();active=process;lock.unlock();defer{lock.lock();if active === process{active=nil};lock.unlock()}
  try process.run();let deadline=Date().addingTimeInterval(timeout)
  while process.isRunning && Date()<deadline{Thread.sleep(forTimeInterval:0.05)}
  if process.isRunning{process.terminate();throw UpdateFailure(message:"更新步骤等待超时，原应用未替换。请使用 DMG 手动安装。")}
  process.waitUntilExit();guard process.terminationStatus==0 else{throw UpdateFailure(message:"更新步骤未完成：\(URL(fileURLWithPath:executable).lastPathComponent)，错误码 \(process.terminationStatus)。")}
 }
}
