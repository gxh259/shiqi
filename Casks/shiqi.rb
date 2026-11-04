cask "shiqi" do
  version "1.3.1"
  sha256 "85d7ae501b151efd6ede68b7e837da37631a93b8ea1fa356db55865b56928b49"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
