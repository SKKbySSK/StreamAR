using System;
using System.IO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace StreamarBroadcaster.Controllers
{
    public abstract class BroadcasterControllerBase : ControllerBase
    {
        protected Uri BaseUri { get; } = new Uri("http://192.168.0.25:5000/");

        protected Uri GetRelativeUrl(string path)
        {
            return new Uri(BaseUri, path);
        }
    }
}