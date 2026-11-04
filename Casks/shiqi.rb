cask "shiqi" do
  version "1.6.0"
  sha256 "b06bc501b3c04b31125bdc1933421826876c2c11dc6748025a66198786774f20"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
