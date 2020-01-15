
"""
    precompile_pather(packageName::String)

To get the path of precompile_packageName.jl file

Written exclusively for SnoopCompile Github actions.
# Examples
```julia
precompilePath, precompileFolder = precompile_pather("MatLang")
```
"""
function precompile_pather(packageName::String)
    return "\"../deps/SnoopCompile/precompile/precompile_$packageName.jl\"",
    "$(pwd())/deps/SnoopCompile/precompile/"
end

precompile_pather(packageName::Symbol) = precompile_pather(string(packageName))
precompile_pather(packageName::Module) = precompile_pather(string(packageName))

################################################################

function precompile_regex(precompilePath)
    # https://stackoverflow.com/questions/3469080/match-whitespace-but-not-newlines
    # {1,} for any number of spaces
    c1 = Regex("#[^\\S\\r\\n]{0,}include\\($(precompilePath)\\)")
    c2 = r"#\s{0,}_precompile_\(\)"
    a1 = "include($precompilePath)"
    a2 = "_precompile_()"
    return c1, c2, a1, a2
end
################################################################

"""
    precompile_activator(packagePath, precompilePath)

Activates precompile of a package by adding or uncommenting include() of *.jl file generated by SnoopCompile and _precompile_().

packagePath is the same as `pathof`. However, `pathof(module)` isn't used to prevent loadnig the package.

Written exclusively for SnoopCompile Github actions.
"""
function precompile_activator(packagePath::String, precompilePath::String)

    packageText = Base.read(packagePath, String)

    c1, c2, a1, a2 = precompile_regex(precompilePath)

    # Checking availability of _precompile_ code
    commented = occursin(c1, packageText) && occursin(c2, packageText)
    available = occursin(a1, packageText) && occursin(a2, packageText)

    if commented
        packageEdited = foldl(replace,
                     (
                      c1 => a1,
                      c2 => a2,
                     ),
                     init = packageText)

                     Base.write(packagePath, packageEdited)

        println("precompile is activated")
    elseif available
        # do nothing
        println("precompile is already activated")
    else
        # TODO: add code automatiaclly
        error(""" add the following codes into your PackageName.jl file under src folder:
         #include($precompilePath)
         #_precompile_()
         """)
    end

end

"""
    precompile_deactivator(packagePath, precompilePath)

Deactivates precompile of a package by commenting include() of *.jl file generated by SnoopCompile and _precompile_().

packagePath is the same as `pathof`. However, `pathof(module)` isn't used to prevent loadnig the package.

Written exclusively for SnoopCompile Github actions.
"""
function precompile_deactivator(packagePath::String, precompilePath::String)

    packageText = Base.read(packagePath, String)

    c1, c2, a1, a2 = precompile_regex(precompilePath)

    # Checking availability of _precompile_ code
    commented = occursin(c1, packageText) && occursin(c2, packageText)
    available = occursin(a1, packageText) && occursin(a2, packageText)

    if available && !commented
        packageEdited = foldl(replace,
                     (
                      a1 => "#"*a1,
                      a2 => "#"*a2,
                     ),
                     init = packageText)

                     Base.write(packagePath, packageEdited)

        println("precompile is deactivated")
    elseif commented
        # do nothing
        println("precompile is already deactivated")
    else
        # TODO: add code automatiaclly
        error(""" add the following codes into your PackageName.jl file under src folder:
         #include($precompilePath)
         #_precompile_()
         """)
    end

end