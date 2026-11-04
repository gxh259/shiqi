cask "shiqi" do
  version "1.3.2"
  sha256 "17bedbd74c988d14fce4c2ab54b47a95a2e706d92e25a1d81546e2136a8bf656"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
