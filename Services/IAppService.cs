﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace Services
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IAppService" in both code and config file together.
    [ServiceContract]
    public interface IAppService
    {
        //
        /// <summary>
        /// Making Test for GET method is working or not
        /// </summary>
        /// <returns>Response from API</returns>
        [OperationContract]
        [WebInvoke(Method = "GET", BodyStyle = WebMessageBodyStyle.WrappedRequest, RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json)]
        string TestGETAPI();

        /// <summary>
        /// Making Test for POST method is working or not
        /// </summary>
        /// <returns>Response from API</returns>
        [OperationContract]
        [WebInvoke(Method = "POST", BodyStyle = WebMessageBodyStyle.WrappedRequest, RequestFormat = WebMessageFormat.Json, ResponseFormat = WebMessageFormat.Json)]
        string TestPOSTAPI();  
        ///
    }
}
