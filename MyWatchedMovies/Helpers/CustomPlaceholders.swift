import HGPlaceholders

extension PlaceholdersProvider {
    static var custom: PlaceholdersProvider {
        let commonStyle = PlaceholderStyle()
        
        var loadingStyle = commonStyle
        loadingStyle.isAnimated = false

        var loadingData: PlaceholderData = .loading
        loadingData.image = UIImage(named: "Table Loading")
        loadingData.action = nil
        let loading = Placeholder(data: loadingData, style: loadingStyle, key: .loadingKey)
        
        var errorData: PlaceholderData = .error
        errorData.action = nil
        let error = Placeholder(data: errorData, style: commonStyle, key: .errorKey)
        
        var noResultsData: PlaceholderData = .noResults
        noResultsData.action = nil
        let noResults = Placeholder(data: noResultsData, style: commonStyle, key: .noResultsKey)
        
        var noConnectionData: PlaceholderData = .noConnection
        noConnectionData.action = nil
        let noConnection = Placeholder(data: noConnectionData, style: commonStyle, key: .noConnectionKey)
        
        let placeholdersProvider = PlaceholdersProvider(loading: loading, error: error, noResults: noResults, noConnection: noConnection)

        placeholdersProvider.add(placeholders: PlaceholdersProvider.searchPlaceholder)
        
        return placeholdersProvider
    }
    
    private static var searchPlaceholder: Placeholder {
        var searchStyle = PlaceholderStyle()
        searchStyle.isAnimated = false
        
        var searchData = PlaceholderData()
        searchData.title = NSLocalizedString("Type anything to search", comment: "")
        searchData.subtitle = NSLocalizedString("Ie.: Lord of the Rings", comment: "")
        searchData.image = UIImage(named: "Table Searching")
        searchData.action = nil
        
        let placeholder = Placeholder(data: searchData, style: searchStyle, key: PlaceholderKey.custom(key: "search"))
        
        return placeholder
    }

}
