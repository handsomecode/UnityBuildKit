class Unitybuildkit < Formula
    desc "A command line tool that generates an iOS application with an embedded Unity scene"
    homepage "https://github.com/handsomecode/UnityBuildKit"
    url "https://github.com/handsomecode/UnityBuildKit/archive/1.1.1.tar.gz"
    sha256 "19dd6959f0aa6b6aaa52a6acb4c9423014f5282a5909da77a5192ae16a29dcca"
    head "https://github.com/handsomecode/UnityBuildKit.git"

    depends_on :xcode

    def install
        system "make", "install", "PREFIX=#{prefix}"
    end
end