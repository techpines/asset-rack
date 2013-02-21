Asset = require('../asset').Asset

class exports.AmdRack extends Asset
    mimetype: 'application/javascript'
    create: (options) ->
        {@paths, @url} = options
        @url ||= '/js/amd-map.js'

        @assets = {}
        for asset in @rack.assets when asset.mimetype.match 'javascript'

            # slice off the leading '/' and trailing '.js'
            alias = asset.url.slice 1, -3
            realUrl = asset.specificUrl.slice 1, -3

            # apply AMD paths
            if @paths
                for {name, location} in @paths
                    alias = alias.replace location, name

            @assets[alias] = realUrl

        @contents = """
            require.config ({
                map: {'*': #{JSON.stringify(@assets)}}
            });
        """
        @emit 'created'
