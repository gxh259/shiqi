cask "shiqi" do
  version "1.5.1"
  sha256 "d1ce944aaf505c1be1e31e95332c8fe07c300bf139a8ebe820437a7ce40e46ad"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
