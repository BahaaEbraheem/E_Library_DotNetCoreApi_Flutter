using E_Library.API.DTOs;
using E_Library.API.Filters;
using E_Library.API.Services;

namespace E_Library.API.Endpoints;

public static class AuthEndpoints
{
    public static void MapAuthEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/api");
        
        // Login endpoint
        group.MapPost("/login", async (LoginDto loginDto, IAuthService authService) =>
        {
            var token = await authService.AuthenticateAsync(loginDto.Username, loginDto.Password);
            if (token == null)
                return Results.Unauthorized();
                
            return Results.Ok(new { Token = token });
        })
        .AddEndpointFilter<ValidationFilter<LoginDto>>();

        // Register endpoint
        group.MapPost("/register", async (RegisterUserDto userDto, IAuthService authService) =>
        {
            var success = await authService.RegisterUserAsync(userDto);
            if (!success)
                return Results.BadRequest("Username already exists");
                
            return Results.Ok(new { Message = "User registered successfully" });
        })
        .AddEndpointFilter<ValidationFilter<RegisterUserDto>>();
    }
}