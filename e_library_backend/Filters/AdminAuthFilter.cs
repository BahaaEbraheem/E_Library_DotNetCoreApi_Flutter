using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace e_library_backend.Filters;

public class AdminAuthFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var httpContext = context.HttpContext;

        // Check if user is authenticated
        if (!httpContext.User.Identity?.IsAuthenticated ?? true)
        {
            return Results.Unauthorized();
        }

        // Check if user is admin
        var isAdmin = httpContext.User.Claims
            .FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value == "Admin";

        if (!isAdmin)
        {
            var problemDetails = new ProblemDetails
            {
                Status = 403,
                Title = "Forbidden",
                Detail = "You need administrator privileges to perform this action."
            };

            return Results.Problem(problemDetails);
        }

        return await next(context);
    }
}


