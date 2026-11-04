cask "shiqi" do
  version "1.2.0"
  sha256 "beaef46ccd4097eb31ab12cd68764f73d0220779ec66e1f2b894083cf333c4ac"

  url "https://github.com/gxh259/shiqi/releases/download/v#{version}/ShiQi-#{version}-universal.dmg"
  name "诗栖"
  name "ShiQi"
  desc "Offline poetry and landscape desktop wallpaper"
  homepage "https://github.com/gxh259/shiqi"

  depends_on macos: :ventura
  app "诗栖.app"
end
