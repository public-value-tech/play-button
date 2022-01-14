import Danger

let danger = Danger()

let editedFiles = danger.git.modifiedFiles + danger.git.createdFiles
let additions = danger.github.pullRequest.additions ?? 0
let deletions = danger.github.pullRequest.deletions ?? 0
let changedFiles = danger.github.pullRequest.changedFiles ?? 0

// No Copyright in files
let swiftFilesWithCopyright = editedFiles.filter {
  $0.contains("Copyright") && ($0.fileType == .swift)
}

for file in swiftFilesWithCopyright {
  fail(message: "Please remove this copyright header", file: file, line: 0)
}

// Warn for big PRs
var bigPRThreshold = 600
if (additions + deletions > bigPRThreshold) {
  warn("Pull Request size seems relatively large. If this Pull Request contains multiple changes, please split each into separate PR will helps faster, easier review.");
}

// Require some PR description
if danger.github.pullRequest.body == nil || danger.github.pullRequest.body!.isEmpty {
  fail("PR has no description. 📝 You should provide a description of the changes you have made.")
}

// PR title validation
let prTitle = danger.github.pullRequest.title

if prTitle.contains("WIP") {
  warn("PR is classed as _Work in Progress_.")
}

if prTitle.count < 5 {
  fail("PR title is too short. 🙏 Please use a more descriptive title explaining what you want to change.")
}

message("🎉 The PR added \(additions) and removed \(deletions) lines. 🗂 \(changedFiles) files changed.")
