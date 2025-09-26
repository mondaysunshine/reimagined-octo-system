# HTML Canonical Tag Manager

A powerful PowerShell script that automatically adds, replaces, or removes canonical tags from HTML files across entire website directories. Perfect for SEO optimization, website migrations, and bulk HTML management.

## ✨ Features

- 🌐 **Universal Domain Support** - Works with any website domain
- 🎯 **Smart Tag Management** - Skip, replace, or remove existing canonical tags
- 🔍 **Input Validation** - Automatically cleans and validates domain names
- 📁 **Recursive Processing** - Handles nested folder structures automatically
- 🔄 **Mistake Recovery** - Built-in option to undo and re-run with different settings
- 🛡️ **Safe Operation** - Comprehensive error handling and user confirmations
- 📊 **Progress Tracking** - Clear status messages and summary reports

## 🚀 Quick Start

1. **Download** the script file `canonical-tag-manager.ps1`
2. **Place** it in your website's root directory or any subdirectory
3. **Run** the script:
   ```powershell
   .\canonical-tag-manager.ps1
   ```
4. **Follow the prompts** to configure your settings

## 📋 Requirements

- Windows PowerShell 5.1+ or PowerShell Core 6.0+
- Write permissions to the HTML files you want to modify
- Execution policy allowing script execution (see [Setup](#setup) below)

## ⚙️ Setup

If you encounter execution policy restrictions, run this command in PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🎮 Usage Examples

### Basic Usage
```powershell
# Run the script and follow interactive prompts
.\canonical-tag-manager.ps1

# Example interaction:
# Enter domain: mywebsite.com
# Include current folder 'blog' in URL paths? (y/n): y
# Choose canonical tag action: 1 (skip existing)
```

### Common Scenarios

**🔄 Website Migration**
- Use option 2 (Replace existing) to update all canonical URLs with your new domain

**🧹 SEO Cleanup** 
- Use option 3 (Remove only) to strip all canonical tags before restructuring

**📈 SEO Enhancement**
- Use option 1 (Skip existing) to safely add canonical tags only where missing

## 📖 How It Works

1. **Domain Input & Validation**
   - Prompts for your website domain
   - Automatically removes http/https and trims spaces
   - Validates domain format and asks for confirmation

2. **Path Configuration**
   - Detects current folder structure
   - Asks whether to include current folder in URL paths
   - Builds appropriate URL structure automatically

3. **Canonical Tag Strategy**
   - **Skip existing**: Only adds tags to files without existing canonical tags
   - **Replace existing**: Removes old canonical tags and adds new ones
   - **Remove only**: Strips all canonical tags without adding new ones

4. **File Processing**
   - Recursively finds all HTML files in directory and subdirectories
   - Inserts canonical tags after `</title>` tags with proper formatting
   - Provides real-time progress feedback

5. **Error Recovery**
   - Option to undo changes and re-run with different settings
   - Comprehensive error handling for individual file failures

## 🎯 Output Examples

The script generates canonical URLs based on your folder structure:

```
Domain: mywebsite.com
Folder structure: /blog/posts/2024/my-post.html
Generated URL: https://mywebsite.com/blog/posts/2024/my-post.html

Canonical tag inserted:
<title>My Blog Post</title>
<link rel="canonical" href="https://mywebsite.com/blog/posts/2024/my-post.html">
```

## 🛡️ Safety Features

- ✅ **Backup-friendly**: Easy to undo with built-in re-run option
- ✅ **Non-destructive**: Only modifies canonical tag lines
- ✅ **Validation**: Confirms domain and settings before processing
- ✅ **Error handling**: Continues processing other files if one fails
- ✅ **Duplicate prevention**: Detects existing canonical tags

## 🤝 Contributing

Contributions are welcome! Please feel free to:

- Report bugs or issues
- Suggest new features
- Submit pull requests
- Improve documentation

## 📝 License

This project is licensed under the MIT License - feel free to use it in your projects, both personal and commercial.

## 🙋‍♀️ Support

If you encounter any issues or have questions:

1. Check the [Issues](../../issues) section for existing solutions
2. Create a new issue with detailed information about your problem
3. Include your PowerShell version and error messages if applicable

## ⭐ Show Your Support

If this tool helped you, please consider giving it a star! It helps others discover the project.

---

**Made with ❤️ for the web development community**

*This tool was born out of the need to efficiently manage canonical tags across hundreds of HTML files. Hope it saves you as much time as it saved us!*
