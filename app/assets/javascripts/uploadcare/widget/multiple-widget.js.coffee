{
  namespace,
  utils,
  jQuery: $
} = uploadcare

namespace 'uploadcare.widget', (ns) ->
  class ns.MultipleWidget extends ns.BaseWidget

    constructor: (element) ->
      @currentGroup = null
      super

    __initOnUploadComplete: ->
      __onUploadComplete = $.Callbacks()
      @onUploadComplete = utils.publicCallbacks __onUploadComplete
      @__onChange.add (group) =>
        group?.promise().done (info) =>
          __onUploadComplete.fire info

    __currentObject: ->
      @currentGroup

    __currentFile: ->
      @currentGroup?.promise()

    __setGroup: (group) =>
      equal = group and @currentGroup and @currentGroup.equal(group)
      bothNull = not group and not @currentGroup
      unless equal or bothNull
        @__reset()
        if group
          @currentGroup = group
          @__watchCurrentObject()

    __clearCurrentObj: ->
      @currentGroup = null

    value: (value) ->
      if value?
        if @element.val() != value
          @__setGroup utils.anyToFileGroup(value, @settings)
        this
      else
        @currentGroup

    reloadInfo: =>
      @__setGroup utils.anyToFileGroup(@element.val(), @settings)
      this

    __handleDirectSelection: (type, data) =>
      files = uploadcare.filesFrom(type, data, @settings)
      if @settings.previewStep
        uploadcare.openDialog(files, @settings).done(@__setGroup)
      else
        @__setGroup uploadcare.fileGroupFrom('files', files, @settings)

    openDialog: (tab) ->
      uploadcare.openDialog(@currentGroup, tab, @settings)
        .done(@__setGroup)
        .fail (group) =>
          unless group?.equal(@currentGroup)
            @__setGroup null
    

    
