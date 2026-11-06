cask "shiqi" do
  version "1.6.3"
  sha256 "0e107b6dfdd589773407c49c67d5bba44f075197534e9bca25ad2aec21889f77"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
