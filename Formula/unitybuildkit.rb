class Unitybuildkit < Formula
    desc "A command line tool that generates an iOS application with an embedded Unity scene"
    homepage "https://github.com/handsomecode/UnityBuildKit"
    url "https://github.com/handsomecode/UnityBuildKit/archive/1.0.1.tar.gz"
    sha256 "506134bdac087ae613d34dcc2078cbda1992aa6a6df5f76d0e0d52e99d0f08f3"
    head "https://github.com/handsomecode/UnityBuildKit.git"

    depends_on :xcode

    def install
        system "make", "install", "PREFIX=#{prefix}"
    end
end