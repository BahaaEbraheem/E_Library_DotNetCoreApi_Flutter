using System.Collections.Generic;
using System.Net;
using System.Text;
using System.Text.Json.Serialization;
using e_library_backend.Data;
using e_library_backend.Endpoints;
using e_library_backend.Repositories;
using e_library_backend.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add database context
builder.Services.AddDbContext<LibraryDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IPasswordService, PasswordService>();

// Add repositories
builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped<IAuthorRepository, AuthorRepository>();
builder.Services.AddScoped<IPublisherRepository, PublisherRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();

// Add JWT authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.ASCII.GetBytes(builder.Configuration["Jwt:Key"] ?? "YourSecretKeyHere12345678901234567890")),
            ValidateIssuer = false,
            ValidateAudience = false,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

// Add authorization policies
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));
});

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});



var app = builder.Build();

// تهيئة قاعدة البيانات وتعبئة البيانات الأولية
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<LibraryDbContext>();

        // التحقق من إمكانية الاتصال بقاعدة البيانات
        context.Database.CanConnect();
        Console.WriteLine("تم الاتصال بقاعدة البيانات بنجاح");

        // تطبيق الهجرات لإنشاء الجداول إذا لم تكن موجودة
        context.Database.Migrate();
        Console.WriteLine("تم تطبيق الهجرات بنجاح");

        // التحقق من وجود البيانات وإضافتها إذا لم تكن موجودة
        SeedInitialData(context);
        Console.WriteLine("تم التحقق من البيانات الأولية");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"حدث خطأ أثناء تهيئة قاعدة البيانات: {ex.Message}");
    }
}

// Configure middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "E-Library API V1");
        c.RoutePrefix = "swagger";
    });
}

// دالة لتعبئة البيانات الأولية إذا لم تكن موجودة
void SeedInitialData(LibraryDbContext context)
{
    bool anyChanges = false;

    // التحقق من وجود المستخدمين
    if (!context.Users.Any())
    {
        Console.WriteLine("إضافة بيانات المستخدمين...");
        context.Users.Add(new e_library_backend.Models.User
        {
            Username = "admin",
            Password = "admin123",
            FName = "Admin",
            LName = "User",
            IsAdmin = true
        });
        anyChanges = true;
    }

    // التحقق من وجود المؤلفين
    if (!context.Authors.Any())
    {
        Console.WriteLine("إضافة بيانات المؤلفين...");
        context.Authors.AddRange(
            new e_library_backend.Models.Author
            {
                FName = "نجيب",
                LName = "محفوظ",
                Country = "مصر",
                City = "القاهرة"
            },
            new e_library_backend.Models.Author
            {
                FName = "غسان",
                LName = "كنفاني",
                Country = "فلسطين",
                City = "عكا"
            },
            new e_library_backend.Models.Author
            {
                FName = "أحمد",
                LName = "زويل",
                Country = "مصر",
                City = "الإسكندرية"
            }
        );
        anyChanges = true;
    }

    // التحقق من وجود الناشرين
    if (!context.Publishers.Any())
    {
        Console.WriteLine("إضافة بيانات الناشرين...");
        context.Publishers.AddRange(
            new e_library_backend.Models.Publisher
            {
                PName = "دار الشروق",
                City = "القاهرة"
            },
            new e_library_backend.Models.Publisher
            {
                PName = "دار العلم للملايين",
                City = "بيروت"
            },
            new e_library_backend.Models.Publisher
            {
                PName = "مكتبة الأنجلو المصرية",
                City = "القاهرة"
            }
        );
        anyChanges = true;
    }

    // حفظ التغييرات قبل إضافة الكتب
    if (anyChanges)
    {
        context.SaveChanges();
        Console.WriteLine("تم حفظ بيانات المستخدمين والمؤلفين والناشرين");
    }

    // التحقق من وجود الكتب
    if (!context.Books.Any())
    {
        // Get the actual IDs from the database
        var authors = context.Authors.ToList();
        var publishers = context.Publishers.ToList();

        if (authors.Count >= 3 && publishers.Count >= 3)
        {
            Console.WriteLine("إضافة بيانات الكتب...");
            context.Books.AddRange(
                new e_library_backend.Models.Book
                {
                    Title = "اللص والكلاب",
                    Type = "رواية",
                    Price = 15.99M,
                    AuthorId = authors[0].Id,
                    PublisherId = publishers[0].Id
                },
                new e_library_backend.Models.Book
                {
                    Title = "رجال في الشمس",
                    Type = "رواية",
                    Price = 12.50M,
                    AuthorId = authors[1].Id,
                    PublisherId = publishers[1].Id
                },
                new e_library_backend.Models.Book
                {
                    Title = "عصر العلم",
                    Type = "علمي",
                    Price = 25.00M,
                    AuthorId = authors[2].Id,
                    PublisherId = publishers[2].Id
                }
            );
            context.SaveChanges();
            Console.WriteLine("تم حفظ بيانات الكتب");
        }
        else
        {
            Console.WriteLine("لا يمكن إضافة الكتب: عدد المؤلفين أو الناشرين غير كافٍ");
        }
    }

    // طباعة عدد السجلات في كل جدول للتأكد
    Console.WriteLine($"عدد المستخدمين: {context.Users.Count()}");
    Console.WriteLine($"عدد المؤلفين: {context.Authors.Count()}");
    Console.WriteLine($"عدد الناشرين: {context.Publishers.Count()}");
    Console.WriteLine($"عدد الكتب: {context.Books.Count()}");
}

app.UseAuthentication();
app.UseAuthorization();
app.UseCors("AllowAll");

// تعديل هنا: إما تعطيل التحويل في بيئة التطوير أو تحديد المنفذ صراحةً
// if (!app.Environment.IsDevelopment())
// {
//     app.UseHttpsRedirection();
// }
// else
// {
//     // أو استخدم هذا البديل لتحديد المنفذ صراحةً
//     // app.UseHttpsRedirection(new HttpsRedirectionOptions
//     // {
//     //     HttpsPort = 7206
//     // });
// }


// Map API endpoints
app.MapAuthEndpoints();
app.MapBookEndpoints();
app.MapAuthorEndpoints();
app.MapPublisherEndpoints();

// Start the application
app.Run();
