cask "shiqi" do
  version "1.5.0"
  sha256 "3d01fd3037f0f645913ae4255bc2a896a77e437f25331c496cad1357e90cfa11"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
