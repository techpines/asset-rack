
Asset = require('./.').Asset

class exports.ClientRack extends Asset
    url: '/asset-rack.js'
    create: (options) ->
        @assets = {}
        for asset in @rack.assets
            @assets[asset.url] = asset.specificUrl

        @contents = """
            var assets = { 
                assets: #{JSON.stringify(@assets)},
                url: #{(url) -> @assets[url]}
            };
        """
        @emit 'created'
