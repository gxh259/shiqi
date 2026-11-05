cask "shiqi" do
  version "1.6.2"
  sha256 "c069746d3dc7b82eaa941fedce4d9aac437baf35df53054c9a8f4c7429853083"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
