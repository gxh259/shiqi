cask "shiqi" do
  version "1.6.1"
  sha256 "b71e159306afb4c0de9363551e55a32646d1eb8079adcf0d886350e990773231"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
