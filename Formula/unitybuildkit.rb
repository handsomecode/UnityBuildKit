class UnityBuildKit < Formula
    desc "A command line tool that generates an iOS application with an embedded Unity scene"
    homepage "https://github.com/handsomecode/UnityBuildKit"
    url "https://github.com/handsomecode/UnityBuildKit/archive/0.8.0.tar.gz"
    sha256 "a5041d758130924c92c7c67ec1447fc79de0f28c29dd7437836a676c6501561f"
    head "https://github.com/handsomecode/UnityBuildKit.git"

    depends_on :xcode

    def install
        system "make", "install"
    end
end