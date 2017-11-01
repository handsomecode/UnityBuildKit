class Unitybuildkit < Formula
    desc "A command line tool that generates an iOS application with an embedded Unity scene"
    homepage "https://github.com/handsomecode/UnityBuildKit"
    url "https://github.com/handsomecode/UnityBuildKit/archive/1.0.0.tar.gz"
    sha256 "8a70f1354c2ae2ebd3e8adba3c4f1aa6490c7ce475b5bae7858175f1175344f0"
    head "https://github.com/handsomecode/UnityBuildKit.git"

    depends_on :xcode

    def install
        system "make", "install", "PREFIX=#{prefix}"
    end
end