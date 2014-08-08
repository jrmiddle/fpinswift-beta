func getSwiftFiles(files: [String]) -> [String] {
    var result : [String] = []
    for file in files {
        if file.hasSuffix(".swift") {
            result.append(file)
        }
    }
    return result
}