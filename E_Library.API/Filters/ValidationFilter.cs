using System.ComponentModel.DataAnnotations;
using System.Reflection;

namespace E_Library.API.Filters;

public class ValidationFilter<T> : IEndpointFilter where T : class
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var parameter = context.Arguments.OfType<T>().FirstOrDefault();
        if (parameter == null)
        {
            return Results.BadRequest("Invalid request body");
        }

        var validationContext = new ValidationContext(parameter);
        var validationResults = new List<ValidationResult>();
        
        if (!Validator.TryValidateObject(parameter, validationContext, validationResults, true))
        {
            var errors = validationResults
                .GroupBy(r => r.MemberNames.FirstOrDefault() ?? string.Empty)
                .ToDictionary(
                    g => g.Key,
                    g => g.Select(r => r.ErrorMessage ?? "Invalid value").ToArray()
                );
                
            return Results.ValidationProblem(errors);
        }

        return await next(context);
    }
}



