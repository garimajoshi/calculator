/*
 * Copyright (C) 2013 Garima Joshi
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

public MathFunction : Object
{
    private string _name;
    private string[] _arguments;
    private string _expression;
    private string _description;

    public string name {
        get { return _name; }
    }
    
    public string[] arguments {
        get { return _arguments; }
    }

    public string expression {
        get { return _expression; }
    }
    
    public string description {
        get { return _description; }
    }
    
    public MathFunction (string function_name, string[] arguments, string? expression, string? description)
    {
        _name = function_name;
        _arguments = arguments;
        
        if (expression != null)
            _expression = expression;
        else
            _expression = "";

        if (description != null)
            _description = description;
        else
            _description = "";
    }
    
    Number? virtual evaluate (Number[] args)
    {
        //TODO: implement this
        /*
            1. add temporarily these variables to set of defined variables like
                _arguments[0] = args[0]
                .
                .
                _arguments[n-1] = args[n-1]
            2. create equation object, parse the expression using it
            3. remove temporarily added variables in step 1
        */
    }
}

public BuiltInMathFunction : MathFunction
{
    public BuiltInMathFunction (string function_name, string? description)
    {
        string[] arguments = {};
        string expression = "";
        base (function_name, arguments, expression, description);
    }
    
    Number? override evaluate (Number[] args)
    {
        return evaluate_built_in_function (name, args);
    }
    
    private Number? evaluate_built_in_function (string name, Number[] args)
    {
        var lower_name = name.down ();
        var x = args[0];
        // FIXME: Re Im ?

        if (lower_name == "log")
        {
            if (args.length <= 1)
                return x.logarithm (10); // FIXME: Default to ln
            else
            {
                var number_base = args[1].to_integer ();
                if (number_base < 0)
                    return null;
                else
                    return x.logarithm (number_base);
            }
        }
        else if (lower_name == "ln")
            return x.ln ();
        else if (lower_name == "sqrt") // √x
            return x.sqrt ();
        else if (lower_name == "abs") // |x|
            return x.abs ();
        else if (lower_name == "sgn") //signum function
            return x.sgn ();
        else if (lower_name == "arg")
            return x.arg (equation.angle_units);
        else if (lower_name == "conj")
            return x.conjugate ();
        else if (lower_name == "int")
            return x.integer_component ();
        else if (lower_name == "frac")
            return x.fractional_component ();
        else if (lower_name == "floor")
            return x.floor ();
        else if (lower_name == "ceil")
            return x.ceiling ();
        else if (lower_name == "round")
            return x.round ();
        else if (lower_name == "re")
            return x.real_component ();
        else if (lower_name == "im")
            return x.imaginary_component ();
        else if (lower_name == "sin")
            return x.sin (equation.angle_units);
        else if (lower_name == "cos")
            return x.cos (equation.angle_units);
        else if (lower_name == "tan")
            return x.tan (equation.angle_units);
        else if (lower_name == "sin⁻¹" || lower_name == "asin")
            return x.asin (equation.angle_units);
        else if (lower_name == "cos⁻¹" || lower_name == "acos")
            return x.acos (equation.angle_units);
        else if (lower_name == "tan⁻¹" || lower_name == "atan")
            return x.atan (equation.angle_units);
        else if (lower_name == "sinh")
            return x.sinh ();
        else if (lower_name == "cosh")
            return x.cosh ();
        else if (lower_name == "tanh")
            return x.tanh ();
        else if (lower_name == "sinh⁻¹" || lower_name == "asinh")
            return x.asinh ();
        else if (lower_name == "cosh⁻¹" || lower_name == "acosh")
            return x.acosh ();
        else if (lower_name == "tanh⁻¹" || lower_name == "atanh")
            return x.atanh ();
        else if (lower_name == "ones")
            return x.ones_complement (equation.wordlen);
        else if (lower_name == "twos")
            return x.twos_complement (equation.wordlen);
        return null;
    }   
}
