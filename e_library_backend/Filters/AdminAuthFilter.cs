using System.Security.Claims;
using e_library_backend.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace e_library_backend.Filters;

public class AdminAuthFilter : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var httpContext = context.HttpContext;
        
        // التحقق من وجود رأس التفويض
        if (!httpContext.Request.Headers.TryGetValue("Authorization", out var authHeader))
        {
            return Results.Unauthorized();
        }
        
        var authHeaderValue = authHeader.ToString();
        if (string.IsNullOrEmpty(authHeaderValue) || !authHeaderValue.StartsWith("Bearer "))
        {
            return Results.Unauthorized();
        }
        
        var token = authHeaderValue.Substring("Bearer ".Length).Trim();
        
        // التحقق من صحة التوكن وأن المستخدم هو مسؤول
        try
        {
            // هنا يجب أن تكون لديك منطق للتحقق من التوكن
            // وأن المستخدم هو مسؤول
            
            var userRepository = httpContext.RequestServices.GetRequiredService<IUserRepository>();
            var isAdmin = await userRepository.IsUserAdminByTokenAsync(token);
            
            if (!isAdmin)
            {
                return Results.Forbid();
            }
            
            return await next(context);
        }
        catch
        {
            return Results.Unauthorized();
        }
    }
}
