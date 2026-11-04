cask "shiqi" do
  version "1.4.1"
  sha256 "27ce5680fa276511a3a0ad9b00b2a049ec05f2dced42da51596b1c3a76bc3ca1"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
