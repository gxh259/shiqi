cask "shiqi" do
  version "1.3.0"
  sha256 "53d6f5f2c558bc9b4c6062fc8e2d5fdb849ad2f015c33b4ae104ceb35fdc04fa"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
