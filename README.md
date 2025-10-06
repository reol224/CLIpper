# CLIpper

A cross-platform script that provides system optimization and security tools.

## 🚀 Features



### System Management Tools
- **Comprehensive System Scanning** - Complete system analysis with hardware, network, and performance metrics
- **Quick Scan Mode** - Fast basic system information gathering
- **Modular Scanning** - Individual scans for hardware, network, performance, and security
- **System Cleaning** - Cache, temporary files, and log cleanup
- **Security Auditing** - Vulnerability assessment and security hardening
- **Interactive Menu** - User-friendly menu interface for all operations
- **Export Functionality** - Save scan results to JSON (Linux/macOS) or text files (Windows)
- **Auto-Update System** - Built-in script update mechanism

### Installation & Usage
- **Automatic OS detection** with manual selection fallback
- **Copy-to-clipboard** functionality for easy command execution
- **Step-by-step installation guide** with platform-specific requirements
- **Interactive command reference** with usage examples for all platforms

## 🛠️ Tech Stack

- **Frontend**: React 18 + TypeScript + Vite
- **UI Components**: Radix UI + shadcn/ui
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **Build Tool**: Vite

## 📦 Installation

### Prerequisites
- Node.js 16+ 
- npm or yarn package manager

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd clipper
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

4. **Open in browser**
   ```
   http://localhost:5173
   ```

## 🎯 Usage

### End-User Installation

#### Windows
```bash
# Primary method (using curl)
curl -o clipper_windows.bat https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_windows.bat
clipper_windows.bat --scan

# Alternative (using PowerShell)
Invoke-WebRequest -Uri "https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_windows.bat" -OutFile "clipper_windows.bat"
.\clipper_windows.bat --scan
```

#### Linux
```bash
curl -o clipper_linux.sh https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_linux.sh
chmod +x clipper_linux.sh
./clipper_linux.sh --scan
```

#### macOS
```bash
curl -o clipper_macos.sh https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build/clipper_macos.sh
chmod +x clipper_macos.sh
./clipper_macos.sh --scan
```

### Available Commands

#### Linux Commands
- `./clipper_linux.sh --scan` - Run complete system scan
- `./clipper_linux.sh --scan-quick` - Run quick scan (basic info only)
- `./clipper_linux.sh --hardware` - Show only hardware information
- `./clipper_linux.sh --network` - Show only network information
- `./clipper_linux.sh --performance` - Show only performance metrics
- `./clipper_linux.sh --security` - Run security audit
- `./clipper_linux.sh --clean` - Clean system (cache, temp files, logs)
- `./clipper_linux.sh --export [FILE]` - Export results to JSON file
- `./clipper_linux.sh --menu` - Show interactive menu
- `./clipper_linux.sh --update` - Check for updates and update script
- `./clipper_linux.sh --help` - Show help message
- `./clipper_linux.sh --version` - Show version information

#### Windows Commands
- `clipper_windows.bat --scan` - Run complete system scan
- `clipper_windows.bat --scan-quick` - Run quick scan (basic info only)
- `clipper_windows.bat --hardware` - Show only hardware information
- `clipper_windows.bat --network` - Show only network information
- `clipper_windows.bat --performance` - Show only performance metrics
- `clipper_windows.bat --security` - Run security audit
- `clipper_windows.bat --clean` - Clean system (cache, temp files, logs)
- `clipper_windows.bat --export [FILE]` - Export results to text file
- `clipper_windows.bat --menu` - Show interactive menu
- `clipper_windows.bat --update` - Check for updates and update script
- `clipper_windows.bat --help` - Show help message
- `clipper_windows.bat --version` - Show version information

#### macOS Commands
- `./clipper_macos.sh --scan` - Run complete system scan
- `./clipper_macos.sh --scan-quick` - Run quick scan (basic info only)
- `./clipper_macos.sh --hardware` - Show only hardware information
- `./clipper_macos.sh --network` - Show only network information
- `./clipper_macos.sh --performance` - Show only performance metrics
- `./clipper_macos.sh --security` - Run security audit
- `./clipper_macos.sh --clean` - Clean system (cache, temp files, logs)
- `./clipper_macos.sh --export [FILE]` - Export results to text file
- `./clipper_macos.sh --menu` - Show interactive menu
- `./clipper_macos.sh --update` - Check for updates and update script
- `./clipper_macos.sh --help` - Show help message
- `./clipper_macos.sh --version` - Show version information

## 🏗️ Project Structure

```
src/
├── components/
│   ├── ui/                 # shadcn/ui components (40+ components)
│   ├── InstallationPage.tsx # OS-specific installation guide
│   └── home.tsx           # Home page component
├── lib/
│   └── utils.ts           # Utility functions
├── stories/               # Storybook stories for all UI components
├── types/                 # TypeScript type definitions
└── tempobook/            # Tempo platform storyboards

public/
├── clipper_linux.sh       # Linux system management script
├── clipper_windows.bat    # Windows system management script
└── clipper_macos.sh       # macOS system management script
```

## 🔧 Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## 🌐 Cross-Platform Support

### Windows
- **Script**: `clipper_windows.bat`
- **Download**: curl or PowerShell Invoke-WebRequest
- **Export Format**: Text files
- **Requirements**: Windows 10/11, Command Prompt or PowerShell

### macOS
- **Script**: `clipper_macos.sh`
- **Download**: curl
- **Export Format**: Text files
- **Requirements**: macOS 10.15+, Terminal, chmod permissions

### Linux
- **Script**: `clipper_linux.sh`
- **Download**: curl or wget
- **Export Format**: JSON files
- **Requirements**: bash shell, chmod permissions, standard Linux utilities

## 🔒 Security Features

- **System Security Audit**: Comprehensive security vulnerability assessment
- **Performance Monitoring**: Real-time system performance metrics
- **Hardware Analysis**: Detailed hardware information and health checks
- **Network Security**: Network configuration and security analysis
- **System Cleaning**: Safe removal of temporary files, cache, and logs

## 🚀 Performance Optimization

- **Quick Scan Mode**: Fast system overview for immediate insights
- **Modular Scanning**: Target specific system areas for focused analysis
- **Export Capabilities**: Save results for later analysis and reporting
- **Interactive Menu**: User-friendly interface for non-technical users
- **Auto-Update**: Keep scripts current with latest features and security patches

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

Need help? 
- Run `--help` with any script for detailed usage information
- Check the installation guide in the web interface
- Review the command reference for your specific platform

## 🔗 Links

- [Live Demo](https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build)
- [Script Downloads](https://aa6f8cd6-9526-49fe-9abe-c7500cf69a7c.canvases.tempo.build)

---

Built with ❤️