cask "shiqi" do
  version "1.6.4"
  sha256 "82f51ae1fd9d7d9147debb890684ea1fdbea5179f0a299de686545e6660199c7"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
