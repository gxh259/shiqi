cask "shiqi" do
  version "1.7.0"
  sha256 "c651a0812bd334f041b2df436731e4ce45788194ce732cfa3b1857217263e6c7"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
