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

export default function InstallationPage() {
  const [detectedOS, setDetectedOS] = useState<string>("");
  const [copiedCommand, setCopiedCommand] = useState<string | null>(null);
  const [updateAvailable, setUpdateAvailable] = useState(false);
  const [latestVersion, setLatestVersion] = useState("1.0.2");

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
      "irm https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/install.ps1 | iex",
    macos:
      "curl -fsSL https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/install.sh | bash",
    linux:
      "curl -fsSL https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/install.sh | sudo bash",
  };

  const downloadLinks = {
    windows:
      "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper-windows.exe",
    macos:
      "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper-macos.tar.gz",
    linux:
      "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper-linux.tar.gz",
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
      installCommand: "npm install -g clipper-cli",
      runCommand: "clipper --scan",
      requirements: [
        "Node.js 16+",
        "Administrator privileges",
        "Windows 10/11",
      ],
      downloadUrl: "https://nodejs.org/download",
    },
    macos: {
      name: "macOS",
      icon: <HardDrive className="w-5 h-5" />,
      installCommand: "brew install clipper-cli",
      runCommand: "clipper --scan",
      requirements: ["Homebrew", "macOS 10.15+", "Xcode Command Line Tools"],
      downloadUrl: "https://brew.sh",
    },
    linux: {
      name: "Linux",
      icon: <Terminal className="w-5 h-5" />,
      installCommand: "sudo apt install clipper-cli",
      runCommand: "clipper --scan",
      requirements: ["Ubuntu/Debian based", "sudo privileges", "curl/wget"],
      downloadUrl: "https://github.com/clipper/releases",
    },
  };

  // Check for updates on page load
  useEffect(() => {
    const checkForUpdates = () => {
      // Simulate update check - in real app this would call GitHub API
      const hasUpdate = Math.random() > 0.6; // 40% chance
      setUpdateAvailable(hasUpdate);
    };

    checkForUpdates();
  }, []);

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
        {updateAvailable && (
          <Alert className="mt-4 bg-yellow-900 border-yellow-600">
            <AlertTitle className="text-yellow-400 flex items-center gap-2">
              🔄 Update Available
            </AlertTitle>
            <AlertDescription className="text-yellow-200">
              CLIpper v{latestVersion} is now available!
              <a
                href="/terminal"
                className="ml-2 underline hover:text-yellow-100"
              >
                Open terminal and run "clipper --upgrade"
              </a>
            </AlertDescription>
          </Alert>
        )}

        <div className="mt-4 flex gap-3">
          <a
            href="/terminal"
            className="inline-flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-black rounded font-medium transition-colors"
          >
            <Terminal className="w-4 h-4" />
            Launch Terminal Interface
          </a>
          <a
            href={downloadLinks[detectedOS]}
            className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded font-medium transition-colors"
          >
            <Download className="w-4 h-4" />
            Download CLIpper
          </a>
          {updateAvailable && (
            <a
              href={downloadLinks[detectedOS]}
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

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
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
                <Button size="sm" variant="outline" asChild className="w-full">
                  <a
                    href={downloadLinks[detectedOS]}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    Download
                  </a>
                </Button>
              </CardContent>
            </Card>

            <Card className="bg-gray-800 border-gray-600">
              <CardContent className="p-4 text-center">
                <ExternalLink className="w-8 h-8 mx-auto mb-2 text-purple-400" />
                <h3 className="font-semibold mb-1">Web Version</h3>
                <p className="text-sm text-gray-400 mb-3">Use online</p>
                <Button size="sm" variant="outline" asChild className="w-full">
                  <a href="/terminal" target="_blank" rel="noopener noreferrer">
                    Launch Web
                  </a>
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
              <h4 className="text-white font-medium">Available Commands:</h4>
              <div className="text-sm text-gray-300 space-y-1">
                <div>
                  <code className="text-green-400">--scan</code> - Run system
                  scan
                </div>
                <div>
                  <code className="text-green-400">--optimize</code> - Optimize
                  system
                </div>
                <div>
                  <code className="text-green-400">--security</code> - Security
                  check
                </div>
                <div>
                  <code className="text-green-400">--help</code> - Show all
                  commands
                </div>
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
