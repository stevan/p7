<!----------------------------------------------------------------------------->
# NOTES
<!----------------------------------------------------------------------------->


<!----------------------------------------------------------------------------->
## Modules
<!----------------------------------------------------------------------------->

- Modules have a namespace
    - it should be all lowercase names
        - following Java package naming conventions
    - ??? should they use ' package seperator?
        - `org'p7'util'function` instead of `org::p7::util::function`

### Using a Module

- importing from modules looks like this:
    - `use org::p7::util::function qw[ ClassToLoad ];`
    - Modules can be used to load classes and packages
        - if there is an import() it will be called
        - modules will not be reloaded
            - but the import() will be called if needed

- modules should be imported at the top of a file
    - prior to declaring the class or package for that file
    - any modules imports are lexical
        - they do NOT alter the namespace they are being imported into
        - the imports are file scoped
            - so are available in any classes or packages defined in the file
            - and go out of scope at the end of the file


### Developing a Module

- classes within a module can just `use` one another
    - as long as they declare the module they are in
        - `use module qw[ org::p7::util::stream ];`
    - this will push the appropriate directory onto @INC
        - FIXME: this is not ideal (see NOTE below)
            - perhaps we should add a UNITCHECK to pop the dir off of @INC?
                - this works, but would be ugly and require a module
            - or add a CODE ref to @INC to handle loading?
                - this requires some rethinking

- any module exports MUST be exported lexically via the import() method
    - using the `builtin::export_lexically` function

- imports from outside packages/modules should be lexical as well
    - using the `importer` module this is possible
    - this helps keep the namespaces clean


NOTE: At the moment importing seems like it will only load this one class (and
any that it loads), but it also ends up leaving the directory in `@INC` so
that might need to be cleaned up.


<!----------------------------------------------------------------------------->
