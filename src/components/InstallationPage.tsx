import React, { useState, useEffect } from "react";
import {
  Terminal,
  Copy,
  Download,
  CheckCircle,
  ExternalLink,
  Monitor,
  HardDrive,
} from "lucide-react";
import { Button } from "./ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "./ui/card";
import { Badge } from "./ui/badge";
import { Alert, AlertDescription, AlertTitle } from "./ui/alert";

interface OSInfo {
  name: string;
  icon: React.ReactNode;
  installCommand: string;
  runCommand: string;
  requirements: string[];
  downloadUrl?: string;
}

interface GitHubRelease {
  tag_name: string;
  name: string;
  published_at: string;
  html_url: string;
}

export default function InstallationPage() {
  const [detectedOS, setDetectedOS] = useState<string>("");
  const [copiedCommand, setCopiedCommand] = useState<string | null>(null);
  const [updateAvailable, setUpdateAvailable] = useState(false);
  const [latestVersion, setLatestVersion] = useState("1.0.0");
  const [currentVersion] = useState("1.0.0"); // This would come from your app config
  const [isCheckingUpdates, setIsCheckingUpdates] = useState(true);

  useEffect(() => {
    // Detect OS from user agent
    const userAgent = navigator.userAgent.toLowerCase();
    if (userAgent.includes("win")) {
      setDetectedOS("windows");
    } else if (userAgent.includes("mac")) {
      setDetectedOS("macos");
    } else if (userAgent.includes("linux")) {
      setDetectedOS("linux");
    } else {
      setDetectedOS("unknown");
    }
  }, []);

  const quickInstallCommands = {
    windows:
      "curl -o clipper_windows.bat https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_windows.bat",
    macos:
      "curl -fsSL https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/install.sh | bash",
    linux:
      "curl -fsSL https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_linux.sh | sudo bash",
  };

  const downloadLinks = {
    windows:
      "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_windows.bat",
    macos:
      "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper-macos.tar.gz",
    linux:
      "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_linux.sh",
  };

  const copyToClipboard = async (text: string, commandType: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopiedCommand(commandType);
      setTimeout(() => setCopiedCommand(null), 2000);
    } catch (err) {
      console.error("Failed to copy text: ", err);
    }
  };

  const osConfigs: Record<string, OSInfo> = {
    windows: {
      name: "Windows",
      icon: <Monitor className="w-5 h-5" />,
      installCommand:
        "curl -o clipper_windows.bat https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_windows.bat",
      runCommand: "clipper --help",
      requirements: ["PowerShell", "Administrator privileges", "Windows 10/11"],
      downloadUrl:
        "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_windows.bat",
    },
    macos: {
      name: "macOS",
      icon: <HardDrive className="w-5 h-5" />,
      installCommand:
        "curl -fsSL https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/install.sh | bash",
      runCommand: "clipper --help",
      requirements: ["Terminal", "macOS 10.15+", "curl"],
      downloadUrl:
        "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper-macos.tar.gz",
    },
    linux: {
      name: "Linux",
      icon: <Terminal className="w-5 h-5" />,
      installCommand:
        "curl -o clipper_linux.sh https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_linux.sh",
      runCommand: "clipper --help",
      requirements: ["Terminal", "sudo privileges", "curl"],
      downloadUrl:
        "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_linux.sh",
    },
  };

  // Check for updates from GitHub releases
  useEffect(() => {
    const checkForUpdates = async () => {
      try {
        setIsCheckingUpdates(true);
        const response = await fetch(
          "https://api.github.com/repos/reol224/CLIpper/releases/latest",
        );

        if (response.ok) {
          const release: GitHubRelease = await response.json();
          const latestVersionTag = release.tag_name.replace(/^v/, ""); // Remove 'v' prefix if present

          setLatestVersion(latestVersionTag);

          // Compare versions (simple string comparison for now)
          // For more complex version comparison, you might want to use a library like semver
          const isNewer = compareVersions(latestVersionTag, currentVersion);
          setUpdateAvailable(isNewer);
        } else {
          console.warn("Failed to fetch latest release from GitHub");
        }
      } catch (error) {
        console.error("Error checking for updates:", error);
      } finally {
        setIsCheckingUpdates(false);
      }
    };

    checkForUpdates();
  }, [currentVersion]);

  // Simple version comparison function
  const compareVersions = (latest: string, current: string): boolean => {
    const latestParts = latest.split(".").map(Number);
    const currentParts = current.split(".").map(Number);

    for (
      let i = 0;
      i < Math.max(latestParts.length, currentParts.length);
      i++
    ) {
      const latestPart = latestParts[i] || 0;
      const currentPart = currentParts[i] || 0;

      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }

    return false; // Versions are equal
  };

  const currentOS = osConfigs[detectedOS] || osConfigs.windows;

  return (
    <div className="min-h-screen bg-black text-white font-mono p-6">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-2">
          <Terminal className="w-6 h-6" />
          <h1 className="text-2xl font-bold">CLIpper</h1>
        </div>
        <p className="text-gray-300">
          Cross-platform system management and security tool
        </p>

        {/* Update Alert */}
        {!isCheckingUpdates && updateAvailable && (
          <Alert className="mt-4 bg-yellow-900 border-yellow-600">
            <AlertTitle className="text-yellow-400 flex items-center gap-2">
              🔄 Update Available
            </AlertTitle>
            <AlertDescription className="text-yellow-200">
              CLIpper v{latestVersion} is now available!
              <a
                href="https://github.com/reol224/CLIpper/releases/latest"
                target="_blank"
                rel="noopener noreferrer"
                className="ml-2 underline hover:text-yellow-100 inline-flex items-center gap-1"
              >
                View release notes
                <ExternalLink className="w-3 h-3" />
              </a>
            </AlertDescription>
          </Alert>
        )}

        <div className="mt-4 flex gap-3">
          <a
            href="https://github.com/reol224/CLIpper/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-black rounded font-medium transition-colors"
          >
            <Download className="w-4 h-4" />
            Releases
          </a>
          {!isCheckingUpdates && updateAvailable && (
            <a
              href="https://github.com/reol224/CLIpper/releases/latest"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-4 py-2 bg-yellow-600 hover:bg-yellow-700 text-black rounded font-medium transition-colors"
            >
              🔄 Update to v{latestVersion}
            </a>
          )}
        </div>
      </div>

      {/* Quick Install Section */}
      <Card className="mb-8 bg-gray-900 border-gray-700">
        <CardHeader>
          <CardTitle className="text-green-400 flex items-center gap-2">
            <Terminal className="w-5 h-5" />
            Quick Install
          </CardTitle>
          <CardDescription className="text-gray-300">
            One-click installation for {currentOS.name}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center gap-2 mb-2">
            <Badge variant="secondary" className="bg-green-600 text-black">
              {currentOS.name}
            </Badge>
            <span className="text-sm text-gray-400">Auto-detected</span>
          </div>

          <div className="bg-black p-4 rounded border border-gray-600">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-gray-400">
                Copy and paste in terminal:
              </span>
              <Button
                size="sm"
                variant="outline"
                onClick={() =>
                  copyToClipboard(quickInstallCommands[detectedOS], "quick")
                }
                className="text-green-400 border-green-400 hover:bg-green-400 hover:text-black"
              >
                {copiedCommand === "quick" ? (
                  <CheckCircle className="w-4 h-4" />
                ) : (
                  <Copy className="w-4 h-4" />
                )}
              </Button>
            </div>
            <code className="text-green-400 text-sm break-all">
              {quickInstallCommands[detectedOS]}
            </code>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
            <Card className="bg-gray-800 border-gray-600">
              <CardContent className="p-4 text-center">
                <Terminal className="w-8 h-8 mx-auto mb-2 text-blue-400" />
                <h3 className="font-semibold mb-1">Command Line</h3>
                <p className="text-sm text-gray-400 mb-3">
                  Install via terminal
                </p>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() =>
                    copyToClipboard(quickInstallCommands[detectedOS], "cli")
                  }
                  className="w-full"
                >
                  {copiedCommand === "cli" ? "Copied!" : "Copy Command"}
                </Button>
              </CardContent>
            </Card>

            <Card className="bg-gray-800 border-gray-600">
              <CardContent className="p-4 text-center">
                <Download className="w-8 h-8 mx-auto mb-2 text-green-400" />
                <h3 className="font-semibold mb-1">Direct Download</h3>
                <p className="text-sm text-gray-400 mb-3">
                  Download executable
                </p>
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => {
                    const link = document.createElement("a");
                    link.href = downloadLinks[detectedOS];
                    link.download = "";
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                  }}
                  className="w-full"
                >
                  Download
                </Button>
              </CardContent>
            </Card>
          </div>
        </CardContent>
      </Card>

      {/* OS Detection */}
      <Card className="bg-gray-900 border-green-500 mb-6">
        <div className="p-6">
          <div className="flex items-center gap-3 mb-4">
            <Badge
              variant="outline"
              className="border-green-500 text-green-400"
            >
              Detected OS
            </Badge>
            <div className="flex items-center gap-2">
              {currentOS.icon}
              <span className="text-white">{currentOS.name}</span>
            </div>
          </div>

          {detectedOS === "unknown" && (
            <p className="text-yellow-400 text-sm">
              ⚠️ Could not detect your OS. Please select manually below.
            </p>
          )}
        </div>
      </Card>

      {/* Installation Instructions */}
      <div className="grid md:grid-cols-2 gap-6 mb-8">
        {/* Install Command */}
        <Card className="bg-gray-900 border-green-500">
          <div className="p-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2 text-white">
              <Download className="w-5 h-5" />
              Installation
            </h3>

            <div className="bg-black border border-green-500 rounded p-4 mb-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-gray-300 text-sm">$ Command Prompt</span>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() =>
                    copyToClipboard(currentOS.installCommand, "install")
                  }
                  className="text-green-400 hover:text-green-300 hover:bg-green-900/20"
                >
                  <Copy className="w-4 h-4" />
                  {copiedCommand === "install" ? "Copied!" : "Copy"}
                </Button>
              </div>
              <code className="text-green-400 break-all">
                {currentOS.installCommand}
              </code>
            </div>

            <div className="space-y-2">
              <h4 className="text-white font-medium">Requirements:</h4>
              <ul className="text-sm text-gray-300 space-y-1">
                {currentOS.requirements.map((req, index) => (
                  <li key={index} className="flex items-center gap-2">
                    <span className="text-green-500">•</span>
                    {req}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </Card>

        {/* Run Command */}
        <Card className="bg-gray-900 border-green-500">
          <div className="p-6">
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2 text-white">
              <Terminal className="w-5 h-5" />
              Usage
            </h3>

            <div className="bg-black border border-green-500 rounded p-4 mb-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-gray-300 text-sm">$ Run Scanner</span>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => copyToClipboard(currentOS.runCommand, "run")}
                  className="text-green-400 hover:text-green-300 hover:bg-green-900/20"
                >
                  <Copy className="w-4 h-4" />
                  {copiedCommand === "run" ? "Copied!" : "Copy"}
                </Button>
              </div>
              <code className="text-green-400 break-all">
                {currentOS.runCommand}
              </code>
            </div>

            <div className="space-y-2">
              <h4 className="text-white font-medium">
                {detectedOS === "linux"
                  ? "Linux Script Commands:"
                  : detectedOS === "windows"
                    ? "Windows Script Commands:"
                    : "Available Commands:"}
              </h4>
              <div className="text-sm text-gray-300 space-y-1">
                {detectedOS === "linux" ? (
                  <>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --scan
                      </code>{" "}
                      - Run comprehensive system scan
                    </div>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --scan-quick
                      </code>{" "}
                      - Quick scan (basic info)
                    </div>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --hardware
                      </code>{" "}
                      - Hardware info only
                    </div>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --network
                      </code>{" "}
                      - Network info only
                    </div>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --performance
                      </code>{" "}
                      - Performance metrics
                    </div>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --clean
                      </code>{" "}
                      - Clean system files
                    </div>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --export [FILE]
                      </code>{" "}
                      - Export to JSON
                    </div>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --help
                      </code>{" "}
                      - Show all commands
                    </div>
                    <div>
                      <code className="text-green-400">
                        ./clipper_linux.sh --version
                      </code>{" "}
                      - Show version
                    </div>
                  </>
                ) : detectedOS === "windows" ? (
                  <>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --scan
                      </code>{" "}
                      - Run comprehensive system scan
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --scan-quick
                      </code>{" "}
                      - Quick scan (basic info)
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --hardware
                      </code>{" "}
                      - Hardware info only
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --network
                      </code>{" "}
                      - Network info only
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --performance
                      </code>{" "}
                      - Performance metrics
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --security
                      </code>{" "}
                      - Security audit
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --clean
                      </code>{" "}
                      - Clean system files
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --export [FILE]
                      </code>{" "}
                      - Export to text file
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --help
                      </code>{" "}
                      - Show all commands
                    </div>
                    <div>
                      <code className="text-green-400">
                        clipper_windows.bat --version
                      </code>{" "}
                      - Show version
                    </div>
                  </>
                ) : (
                  <>
                    <div>
                      <code className="text-green-400">clipper --scan</code> -
                      Run system scan
                    </div>
                    <div>
                      <code className="text-green-400">clipper --optimize</code>{" "}
                      - Optimize system
                    </div>
                    <div>
                      <code className="text-green-400">clipper --security</code>{" "}
                      - Security audit
                    </div>
                    <div>
                      <code className="text-green-400">clipper --help</code> -
                      Show all commands
                    </div>
                  </>
                )}
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* OS Selection */}
      <Card className="bg-gray-900 border-green-500 mb-6">
        <div className="p-6">
          <h3 className="text-lg font-semibold mb-4 text-white">
            Select Your Operating System
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {Object.entries(osConfigs).map(([key, os]) => (
              <Button
                key={key}
                variant={detectedOS === key ? "default" : "outline"}
                className={`flex items-center gap-2 p-4 h-auto ${
                  detectedOS === key
                    ? "bg-green-600 hover:bg-green-700 text-black"
                    : "border-green-500 text-black hover:bg-green-900/20"
                }`}
                onClick={() => setDetectedOS(key)}
              >
                {os.icon}
                <span>{os.name}</span>
              </Button>
            ))}
          </div>
        </div>
      </Card>

      {/* Quick Start */}
      <Card className="bg-gray-900 border-green-500">
        <div className="p-6">
          <h3 className="text-lg font-semibold mb-4 text-white">
            Quick Start Guide
          </h3>
          <div className="space-y-4 text-sm">
            <div className="flex gap-4">
              <Badge className="bg-green-600 text-black min-w-fit">1</Badge>
              <div>
                <p className="text-white font-medium">Install the CLI tool</p>
                <p className="text-gray-300">
                  Run the installation command for your OS
                </p>
              </div>
            </div>
            <div className="flex gap-4">
              <Badge className="bg-green-600 text-black min-w-fit">2</Badge>
              <div>
                <p className="text-white font-medium">Run your first scan</p>
                <p className="text-gray-300">
                  Execute the scan command to analyze your system
                </p>
              </div>
            </div>
            <div className="flex gap-4">
              <Badge className="bg-green-600 text-black min-w-fit">3</Badge>
              <div>
                <p className="text-white font-medium">Review and optimize</p>
                <p className="text-gray-300">
                  Follow the recommendations to improve your system
                </p>
              </div>
            </div>
          </div>
        </div>
      </Card>

      {/* Footer */}
      <div className="mt-8 text-center text-gray-300 text-sm">
        <p>
          Need help? Run <code className="text-green-400">clipper --help</code>{" "}
          for more options
        </p>
      </div>
    </div>
  );
}
