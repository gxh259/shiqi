cask "shiqi" do
  version "1.3.3"
  sha256 "20f02e522a463bc4f3bbaf9176b36f9d1afdf9d531ff034eb57e964757ebb3c5"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
