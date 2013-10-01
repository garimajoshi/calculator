/*
 * Copyright (C) 2013 Garima Joshi
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

private FunctionManager? default_function_manager = null;

public class FunctionManager : Object
{
    private string file_name;
    private HashTable<string, MathFunction> functions;
    private Serializer serializer;

    public FunctionManager ()
    {
        functions = new HashTable <string, MathFunction> (str_hash, str_equal);
        file_name = Path.build_filename (Environment.get_user_data_dir (), "gnome-calculator", "custom-functions");
        serializer = new Serializer (DisplayFormat.SCIENTIFIC, 10, 50);
        serializer.set_radix ('.');
        reload_functions ();
    }

    public static FunctionManager get_default_function_manager ()
    {
        if (default_function_manager == null)
            default_function_manager = new FunctionManager ();
        return default_function_manager;
    }

    private void reload_functions ()
    {
        functions.remove_all ();
        reload_custom_functions ();
        reload_builtin_functions ();
    }

    private void reload_builtin_functions ()
    {
        add (new BuiltInMathFunction ("log", "Logarithm"));
        
        add (new BuiltInMathFunction ("ln", "Natural logarithm"));
        
        add (new BuiltInMathFunction ("sqrt", "Square root"));

        add (new BuiltInMathFunction ("abs", "Absolute value"));

        add (new BuiltInMathFunction ("sgn", "Signum"));

        add (new BuiltInMathFunction ("arg", "Argument"));

        add (new BuiltInMathFunction ("conj", "Conjugate"));
        
        add (new BuiltInMathFunction ("int", "Integer"));

        add (new BuiltInMathFunction ("frac", "Fraction"));

        add (new BuiltInMathFunction ("floor", "Floor"));

        add (new BuiltInMathFunction ("ceil", "Ceiling"));

        add (new BuiltInMathFunction ("round", "Round"));

        add (new BuiltInMathFunction ("re", "Real"));

        add (new BuiltInMathFunction ("im", "Imaginary"));

        add (new BuiltInMathFunction ("sin", "Sine"));

        add (new BuiltInMathFunction ("cos", "Cosine"));
        
        add (new BuiltInMathFunction ("tan", "Tangent"));
        
        add (new BuiltInMathFunction ("asin", "Arc sine"));
        
        add (new BuiltInMathFunction ("acos", "Arc cosine"));

        add (new BuiltInMathFunction ("atan", "Arc tangent"));

        add (new BuiltInMathFunction ("sin⁻¹", "Inverse sine"));
    
        add (new BuiltInMathFunction ("cos⁻¹", "Inverse cosine"));

        add (new BuiltInMathFunction ("tan⁻¹", "Inverse tangent"));

        add (new BuiltInMathFunction ("sinh", "Hyperbolic sine"));

        add (new BuiltInMathFunction ("cosh", "Hyperbolic cosine"));

        add (new BuiltInMathFunction ("tanh", "Hyperbolic tangent"));

        add (new BuiltInMathFunction ("sinh⁻¹", "Hyperbolic arcsine"));

        add (new BuiltInMathFunction ("cosh⁻¹", "Hyperbolic arccosine"));

        add (new BuiltInMathFunction ("tanh⁻¹", "Hyperbolic arctangent"));

        add (new BuiltInMathFunction ("asinh", "Inverse hyperbolic sine"));

        add (new BuiltInMathFunction ("acosh", "Inverse hyperbolic cosine"));

        add (new BuiltInMathFunction ("atanh", "Inverse hyperbolic tangent"));

        add (new BuiltInMathFunction ("ones", "One's complement"));

        add (new BuiltInMathFunction ("twos", "Two's complement"));
    }

    private void reload_custom_functions ()
    {
        string data;
        try
        {
            FileUtils.get_contents (file_name, out data);
        }
        catch (FileError e)
        {
            return;
        }
        var lines = data.split ("\n");
        
        foreach (var line in lines)
        {
            MathFunction? function = parse_function_from_string (line);
            if (function != null)
                functions.insert (function.name, function);
        }
    }

    private MathFunction? parse_function_from_string (string? data)
    {
        // pattern: <name> (<a1>;<a2>;<a3>;...) = <expression> @ <description>
        
        if (data == null)
            return null;
        
        var i = data.index_of_char ('=');
        if (i < 0)
            return null;
        var left = data.substring (0, i).strip ();
        var right = data.substring (i+1).strip ();
        if (left == null || right == null)
            return null;

        var expression = "";
        var description = "";
        i = right.index_of_char ('@');
        if (i < 0)
            expression = right;
        else
        {
            expression = right.substring (0, i).strip ();
            description = right.substring (i+1).strip ();
        }
        if (expression == null)
            return null;

        i = left.index_of_char('(');
        if (i < 0)
            return null;
        var name = left.substring (0, i).strip ();
        var argument_list = left.substring (i+1).strip ();
        if (name == null || argument_list == null)
            return null;
            
        argument_list = argument_list.replace (")", "");
        string[] arguments = argument_list.split_set (";");

        return (new MathFunction (name, arguments, expression, description));
    }

    private void save ()
    {
        var data = "";
        var iter = HashTableIter<string, MathFunction> (functions);
        string name;
        MathFunction math_function;
        while (iter.next (out name, out math_function))
        {
            if (!math_function.is_custom_function ())
                continue;       //skip builtin functions

            data += "%s(%s)=%s@%s\n".printf (math_function.name,
                                             string.joinv (";", math_function.arguments),
                                             math_function.expression,
                                             math_function.description);
        }

        var dir = Path.get_dirname (file_name);
        DirUtils.create_with_parents (dir, 0700);
        try
        {
            FileUtils.set_contents (file_name, data);
        }
        catch (FileError e)
        {
        }
    }

    public string[] get_names ()
    {
        var names = new string[functions.size () + 1];

        var iter = HashTableIter<string, MathFunction> (functions);
        var i = 0;
        string name;
        MathFunction? definition;
        while (iter.next (out name, out definition))
        {
            names[i] = name;
            i++;
        }
        names[i] = null;

        return names;
    }
    
    private bool add (MathFunction new_function)
    {
        MathFunction? existing_function = get (new_function.name);

        if (existing_function != null && !existing_function.is_custom_function ())
            return false;

        if (existing_function != null)
            functions.replace (new_function.name, new_function);
        else
            functions.insert (new_function.name, new_function);
           
        return true;
    }

    public bool add_function_with_properties (string name, string arguments, string description, Parser? root_parser = null)
    {
        var function_string = name + "(" + arguments + ")=" + description;
        MathFunction? new_function = this.parse_function_from_string (function_string);
        
        if (new_function == null || new_function.validate (root_parser) == false)
        {
            root_parser.set_error (ErrorCode.INVALID);
            return false;
        }
            
        var is_function_added = this.add (new_function);
        if (is_function_added)
            save ();

        return is_function_added;
    }
    
    public new MathFunction? get (string name)
    {
        return functions.lookup (name);
    }

    public void delete (string name)
    {
        MathFunction? function = get (name);
        if (function != null && function.is_custom_function ())
        {
            functions.remove (name);
            save ();
        }
    }
    
    public bool is_function_defined (string name)
    {
        name = name.down ();
        if (name.has_prefix ("log") && sub_atoi (name.substring (3)) >= 0)
            return true;
        return functions.contains (name);
    }
    
    public Number? evaluate_function (string name, Number[] args, Parser parser)
    {
        name = name.down ();
        if (name.has_prefix ("log") && sub_atoi (name.substring (3)) >= 0)
        {
            Number log_base = Number.integer (sub_atoi (name.substring (3)));
            args += log_base;
            name = "log";
        }
        
        MathFunction? function = this.get (name);
        if (function == null)
        {
            parser.set_error (ErrorCode.UNKNOWN_FUNCTION);
            return null;
        }
        
        return function.evaluate (args, parser);
    }
    
    public MathFunction[] functions_eligible_for_autocompletion_for_text(string display_text)
    {
        MathFunction[] eligible_functions= {};
        if (display_text.length <= 1)
            return eligible_functions;

        var iter = HashTableIter<string, MathFunction> (functions);
        string function_name;
        MathFunction function;
        while (iter.next (out function_name, out function))
        {
            //check if any prefix with length > 2 of function_name is a suffix of display_text
            for (int len = 2; len <= function_name.length; len++)
            {
                if (display_text.has_suffix (function_name.substring (0, len)))
                {
                    eligible_functions += function;
                    break;
                }
            }
        }
        return eligible_functions;
    }
}
