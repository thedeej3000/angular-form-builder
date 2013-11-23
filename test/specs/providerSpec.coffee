describe 'builder.provider', ->
    fakeModule = null
    builderProvider = null

    beforeEach module('builder')
    beforeEach ->
        fakeModule = angular.module 'fakeModule', ['builder']
        fakeModule.config ($builderProvider) ->
            builderProvider = $builderProvider
    beforeEach module('fakeModule')


    # ----------------------------------------
    # properties
    # ----------------------------------------
    describe '$builder.components', ->
        it 'check $builder.components is empty', inject ($builder) ->
            expect(0).toBe Object.keys($builder.components).length


    describe '$builder.groups', ->
        it 'check $builder.groups is empty', inject ($builder) ->
            expect([]).toEqual $builder.groups

        it 'check $builder.groups will be updated after registerComponent()', inject ($builder) ->
            $builder.registerComponent 'textInput',
                group: 'Default'
                label: 'Text Input'
                description: 'description'
                placeholder: 'placeholder'
                required: no
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            expect(['Default']).toEqual $builder.groups

            $builder.registerComponent 'textArea',
                group: 'Default'
                label: 'Text Area'
                description: 'description'
                placeholder: 'placeholder'
                required: no
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            expect(['Default']).toEqual $builder.groups

            $builder.registerComponent 'textAreaGroupA',
                group: 'GroupA'
                label: 'Text Area'
                description: 'description'
                placeholder: 'placeholder'
                required: no
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            expect(['Default', 'GroupA']).toEqual $builder.groups


    describe '$builder.broadcastChannel', ->
        it 'check $builder.broadcastChannel', inject ($builder) ->
            expect
                updateInput: '$updateInput'
            .toEqual $builder.broadcastChannel


    describe '$builder.forms', ->
        it 'check $builder.forms', inject ($builder) ->
            expect
                default: []
            .toEqual $builder.forms


    describe '$builderProvider.formsId', ->
        it 'check $builderProvider.formsId', ->
            expect
                default: 0
            .toEqual builderProvider.formsId


    describe '$builderProvider.convertComponent', ->
        it 'check $builderProvider.convertComponent() argument without template', ->
            spyOn(console, 'error').andCallFake (msg) ->
                expect(msg).toEqual 'The template is empty.'
            builderProvider.convertComponent 'inputText',
                popoverTemplate: "<div class='form-group'></div>"
            expect(console.error).toHaveBeenCalled()

        it 'check $builderProvider.convertComponent() argument without popoverTemplate', ->
            spyOn(console, 'error').andCallFake (msg) ->
                expect(msg).toEqual 'The popoverTemplate is empty.'
            builderProvider.convertComponent 'inputText',
                template: "<div class='form-group'></div>"
            expect(console.error).toHaveBeenCalled()

        it 'check $builderProvider.convertComponent() with default', ->
            component = builderProvider.convertComponent 'inputText',
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            expect
                name: 'inputText'
                group: 'Default'
                label: ''
                description: ''
                placeholder: ''
                editable: yes
                required: no
                validation: '/.*/'
                errorMessage: ''
                options: []
                arrayToText: no
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            .toEqual component

        it 'check $builderProvider.convertComponent()', ->
            component = builderProvider.convertComponent 'inputText',
                group: 'GroupA'
                label: 'Input Text'
                description: 'description'
                placeholder: 'placeholder'
                editable: no
                required: yes
                validation: '/regexp/'
                errorMessage: 'error message'
                options: ['value one']
                arrayToText: yes
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            expect
                name: 'inputText'
                group: 'GroupA'
                label: 'Input Text'
                description: 'description'
                placeholder: 'placeholder'
                editable: no
                required: yes
                validation: '/regexp/'
                errorMessage: 'error message'
                options: ['value one']
                arrayToText: yes
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            .toEqual component


    describe '$builderProvider.convertFormObject', ->
        it 'check $builderProvider.convertFormObject() argument with the not exist component', ->
            expect ->
                builderProvider.convertFormObject 'default',
                    component: 'input'
            .toThrow()

        it 'check $builderProvider.convertFormObject() with default value', inject ($builder) ->
            # Register the component `inputText`.
            $builder.registerComponent 'inputText',
                group: 'GroupA'
                label: 'Input Text'
                description: 'description'
                placeholder: 'placeholder'
                editable: yes
                required: yes
                validation: '/regexp/'
                errorMessage: 'error message'
                options: ['value one']
                arrayToText: yes
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            formObject = builderProvider.convertFormObject 'default',
                component: 'inputText'

            expect
                id: 0
                component: 'inputText'
                editable: yes
                index: 0
                label: 'Input Text'
                description: 'description'
                placeholder: 'placeholder'
                options: ['value one']
                required: yes
                validation: '/regexp/'
                errorMessage: 'error message'
            .toEqual formObject

        it 'check $builderProvider.convertFormObject()', inject ($builder) ->
            $builder.registerComponent 'inputText',
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"

            formObject = builderProvider.convertFormObject 'default',
                component: 'inputText'
                editable: no
                label: 'input label'
                description: 'description A'
                placeholder: 'placeholder A'
                options: ['value']
                required: no
                validation: '/.*/'
                errorMessage: 'error'

            expect
                id: 0
                component: 'inputText'
                editable: no
                index: 0
                label: 'input label'
                description: 'description A'
                placeholder: 'placeholder A'
                options: ['value']
                required: no
                validation: '/.*/'
                errorMessage: 'error'
            .toEqual formObject


    describe '$builderProvider.reindexFormObject', ->
        it 'check $builderProvider.reindexFormObject()', ->
            builderProvider.forms.default.push index: 0
            builderProvider.forms.default.push index: 0

            calledCount = jasmine.createSpy 'calledCount'
            builderProvider.reindexFormObject 'default'
            for index in [0..builderProvider.forms.default.length - 1] by 1
                formObject = builderProvider.forms.default[index]
                expect(formObject.index).toBe index
                calledCount()
            expect(calledCount.calls.length).toBe 2


    describe '$builder.registerComponent', ->
        it 'check $builder.registerComponent()', inject ($builder) ->
            $builder.registerComponent 'textInput',
                group: 'Default'
                label: ''
                description: ''
                placeholder: ''
                editable: yes
                required: no
                validation: '/.*/'
                errorMessage: ''
                options: []
                arrayToText: no
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"

            expect
                name: 'textInput'
                group: 'Default'
                label: ''
                description: ''
                placeholder: ''
                editable: yes
                required: no
                validation: '/.*/'
                errorMessage: ''
                options: []
                arrayToText: no
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            .toEqual $builder.components.textInput

        it 'check $builder.registerComponent() the same component will call console.error()', inject ($builder) ->
            $builder.registerComponent 'textInput',
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            spyOn(console, 'error').andCallFake (msg) ->
                expect('The component textInput was registered.').toEqual msg
            $builder.registerComponent 'textInput',
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"
            expect(console.error).toHaveBeenCalled()


    describe '$builder.addFormObject', ->
        beforeEach -> inject ($builder) ->
            $builder.registerComponent 'inputText',
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"

        it 'check $builder.addFormObject() will call $builderProvider.insertFormObject()', inject ($builder) ->
            spyOn(builderProvider, 'insertFormObject').andCallFake (name, index, formObject) ->
                expect(name).toEqual 'default'
                expect(index).toBe 0
                expect
                    component: 'inputText'
                .toEqual formObject
            $builder.addFormObject 'default', component: 'inputText'
            expect(builderProvider.insertFormObject).toHaveBeenCalled()


    describe '$builder.insertFormObject', ->
        beforeEach -> inject ($builder) ->
            $builder.registerComponent 'inputText',
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"

        it 'check $builder.insertFormObject() a new form', inject ($builder) ->
            $builder.insertFormObject 'form', 0, component: 'inputText'
            expect(builderProvider.forms.form.length).toBe 1
            expect(builderProvider.formsId.form).toBe 1

        it 'check $builder.insertFormObject() index out of bound', inject ($builder) ->
            spyOn(builderProvider.forms.default, 'splice').andCallFake (index, length) ->
                expect(index).toBe 0
                expect(length).toBe 0
            $builder.insertFormObject 'default', 1000, component: 'inputText'
            expect(builderProvider.forms.default.splice).toHaveBeenCalled()

        it 'check $builder.insertFormObject() index less than 0', inject ($builder) ->
            spyOn(builderProvider.forms.default, 'splice').andCallFake (index, length) ->
                expect(index).toBe 0
                expect(length).toBe 0
            $builder.insertFormObject 'default', -1, component: 'inputText'
            expect(builderProvider.forms.default.splice).toHaveBeenCalled()

        it 'check $builder.insertFormObject()', inject ($builder) ->
            $builder.insertFormObject 'default', 0, component: 'inputText'
            spyOn(builderProvider.forms.default, 'splice').andCallFake (index, length) ->
                expect(index).toBe 1
                expect(length).toBe 0
            $builder.insertFormObject 'default', 1, component: 'inputText'
            expect(builderProvider.forms.default.splice).toHaveBeenCalled()

        it 'check $builder.insertFormObject() will call convertFormObject() and reindexFormObject()', inject ($builder) ->
            spyOn(builderProvider, 'convertFormObject').andCallFake (name, formObject) ->
                expect(name).toEqual 'default'
                expect
                    component: 'inputText'
                .toEqual formObject
            spyOn(builderProvider, 'reindexFormObject').andCallFake (name) ->
                expect(name).toEqual 'default'
            $builder.insertFormObject 'default', 1, component: 'inputText'
            expect(builderProvider.convertFormObject).toHaveBeenCalled()
            expect(builderProvider.reindexFormObject).toHaveBeenCalled()

    describe '$builder.removeFormObject', ->
        beforeEach -> inject ($builder) ->
            $builder.registerComponent 'inputText',
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"

        it 'check $builder.removeFormObject() will call formObject.splice() and reindexFormObject()', inject ($builder) ->
            spyOn(builderProvider.forms.default, 'splice').andCallFake (index, length, object) ->
                expect(index).toBe 1
                expect(length).toBe 1
                expect(object).toBeUndefined()
            spyOn(builderProvider, 'reindexFormObject').andCallFake (name) ->
                expect(name).toEqual 'default'
            $builder.removeFormObject 'default', 1
            expect(builderProvider.forms.default.splice).toHaveBeenCalled()
            expect(builderProvider.reindexFormObject).toHaveBeenCalled()

    describe '$builder.updateFormObjectIndex', ->
        beforeEach -> inject ($builder) ->
            $builder.registerComponent 'inputText',
                template: "<div class='form-group'></div>"
                popoverTemplate: "<div class='form-group'></div>"

        it 'check $builder.updateFormObjectIndex() will directive return if the new index and the old index are the same one', inject ($builder) ->
            spyOn builderProvider.forms.default, 'splice'
            spyOn builderProvider, 'reindexFormObject'
            $builder.updateFormObjectIndex 'default', 0, 0
            expect(builderProvider.forms.default.splice).not.toHaveBeenCalled()
            expect(builderProvider.reindexFormObject).not.toHaveBeenCalled()

        it 'check $builder.updateFormObjectIndex() will call formObject.splice() and reindexFormObject()', inject ($builder) ->
            formObject = id: 0
            spySplice = spyOn(builderProvider.forms.default, 'splice').andCallFake (index, length, object) ->
                switch spySplice.calls.length
                    when 1
                        expect(index).toBe 0
                        expect(length).toBe 1
                        expect(object).toBeUndefined()
                        [formObject]
                    when 2
                        expect(index).toBe 1
                        expect(length).toBe 0
                        expect(object).toBe formObject
                    else
            spyOn builderProvider, 'reindexFormObject'
            $builder.updateFormObjectIndex 'default', 0, 1
            expect(spySplice.calls.length).toBe 2
            expect(builderProvider.reindexFormObject).toHaveBeenCalled()

    describe '$builder.$get', ->
        it 'check $builder.components is equal $builderProvider.components', inject ($builder) ->
            expect($builder.components).toBe builderProvider.components
        it 'check $builder.groups is equal $builderProvider.groups', inject ($builder) ->
            expect($builder.groups).toBe builderProvider.groups
        it 'check $builder.forms is equal $builderProvider.forms', inject ($builder) ->
            expect($builder.forms).toBe builderProvider.forms
        it 'check $builder.broadcastChannel is equal $builderProvider.broadcastChannel', inject ($builder) ->
            expect($builder.broadcastChannel).toBe builderProvider.broadcastChannel
        it 'check $builder.registerComponent is equal $builderProvider.registerComponent', inject ($builder) ->
            expect($builder.registerComponent).toBe builderProvider.registerComponent
        it 'check $builder.addFormObject is equal $builderProvider.addFormObject', inject ($builder) ->
            expect($builder.addFormObject).toBe builderProvider.addFormObject
        it 'check $builder.insertFormObject is equal $builderProvider.insertFormObject', inject ($builder) ->
            expect($builder.insertFormObject).toBe builderProvider.insertFormObject
        it 'check $builder.removeFormObject is equal $builderProvider.removeFormObject', inject ($builder) ->
            expect($builder.removeFormObject).toBe builderProvider.removeFormObject
        it 'check $builder.updateFormObjectIndex is equal $builderProvider.updateFormObjectIndex', inject ($builder) ->
            expect($builder.updateFormObjectIndex).toBe builderProvider.updateFormObjectIndex
