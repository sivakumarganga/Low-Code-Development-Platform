<%@ Control Language="c#" Inherits="RO.Web.MyAccountModule" CodeFile="MyAccountModule.ascx.cs" CodeFileBaseClass="RO.Web.ModuleBase" %>
<%@ Register TagPrefix="rcasp" Namespace="RoboCoder.WebControls" Assembly="WebControls, Culture=neutral" %>

<script type="text/javascript" lang="javascript">
    var myMachine = null;
    var appSig = null;

    if (navigator.serviceWorker
    && window.Notification
    && window.firebase
    && window.firebaseConfig
    ) {
        firebase.initializeApp(firebaseConfig);
        register_fcm_sw();
    }

    function enableNotification(evt) {
        if (evt.target.checked) {
            setupFCM(firebase.messaging(), undefined, '/' + appSig, vapidKey)
            .then(function (token) {
                $("#<%= cFCMToken.ClientID %>").val(token);
            })
            .catch(function (err) {
                console.log(err);
            });
        }
        else {
            $("#<%= cFCMToken.ClientID %>").val('');
        }
    }

    function mkFingerprint(components) {
        components.sort();
        var a = JSON.stringify(components);
        var sha256 = new sjcl.hash.sha256();
        sha256.update(a);
        var h = btoa(sha256.finalize());
        myMachine = h;
        var appDomainUrl = $("#<%= cAppDomainUrl.ClientID %>").val();
        var lnk = document.createElement("a");
        lnk.href = appDomainUrl;
        var appPath = lnk.pathname;
        var appIdKey = appPath.replace(/^\//, '') + '_AppSig';
        if (!localStorage[appIdKey]) {
            localStorage[appIdKey] = createUUID();
        };
        appSig = localStorage[appIdKey];
        $("#<%= cMyMachine.ClientID %>").val(myMachine);
        $("#<%= cMyAppSig.ClientID %>").val(appSig);
    }

    if (window.requestIdleCallback) {
        requestIdleCallback(function () {
            Fingerprint2.get(mkFingerprint)
        })
    } else {
        setTimeout(function () {
            Fingerprint2.get(mkFingerprint)
        }, 500)
    }

    $(document).ready(function () {
        RetrieveBrowserCap(AsyncInform, { url: 'AdminWs.asmx/BrowserCap', success: function (result) { /*alert(result.d);*/ }, error: function (xhr, er) { } });
        if (navigator.serviceWorker
            &&
            window.Notification
            &&
            window.firebaseConfig
            &&
            Notification.permission !== "denied") {
            $('#EnableNotificationPanel').show();
        }
    });
    function Login() {
        //remove any current flags and red borders
        $(".flag").remove();
        $(".input").each(function () {
            if ($(this).data("originalBorderColor") != undefined) {
                $(this).css("borderColor", $(this).data("originalBorderColor"));
                $(this).removeData()
            }
        });
        //validate flag
        var Labels = <%= this.ClientID %>_Labels;
        $isValid = true;
        $mandatory_message = Labels["RequiredFieldMsg"]; // "* Required Field";
        if (!isNotNullOrEmpty($(".input #<%= cLoginName.ClientID %>"))) {
            $isValid = false;
            flagInput($("#<%= cLoginName.ClientID %>").parent(), $mandatory_message);
        }
        if (!isNotNullOrEmpty($(".input #<%= cUsrPassword.ClientID %>"))) {
            $isValid = false;
            flagInput($("#<%= cUsrPassword.ClientID %>").parent(), $mandatory_message);
        }
        if ($(".input #<%= cMathAnswer.ClientID %>").length > 0 && !isNotNullOrEmpty($(".input #<%= cMathAnswer.ClientID %>"))) {
            $isValid = false;
            flagInput($("#<%= cMathAnswer.ClientID %>").parent(), $mandatory_message);
        }
        if (!$isValid) {
            $(".flag:first").next("input").focus();
            return false;
        }
        return true;
    }

    function PromptCurrentPassword(fnOK, fnCancel) {
        var x = $('#<%= ConfirmPwdPanel.ClientID %>').dialog({
            autoOpen: false,
            show: "blind",
            hide: "blind",
            modal: true,
            buttons: {
                'ok': fnOK,
                'cancel': function () { $(this).dialog('close'); }
            },
            open: function (event, ui) {
                $('#<%=cUsrPasswordVerify.ClientID %>').focus();
                $('#<%= ConfirmPwdPanel.ClientID %>').keypress(function (e) {
                    if (e.keyCode == $.ui.keyCode.ENTER) { $(this).parent().find('.ui-dialog-buttonpane button:first').click(); }
                });
            }
        }).parent().appendTo("form:first");
        $('#<%= ConfirmPwdPanel.ClientID %>').dialog('open');
    }

    function ResetPassword() {
        //remove any current flags and red borders
        $(".flag").remove();
        $(".input").each(function () {
            if ($(this).data("originalBorderColor") != undefined) {
                $(this).css("borderColor", $(this).data("originalBorderColor"));
                $(this).removeData()
            }
        });
        //validate flag
        var Labels = <%= this.ClientID %>_Labels;
        $isValid = true;
        $mandatory_message = Labels["RequiredFieldMsg"]; // "* Required Field";
        $fillOne_message = Labels["NeedLoginOrEmailMsg"] // "* Required at least one";
        $invalid_email_message = Labels["InvalidEmailMsg"]; // "* Not a valid email";
        if (!isNotNullOrEmpty($(".input #<%= cResetLoginName.ClientID %>")) && !isNotNullOrEmpty($(".input #<%= cResetUsrEmail.ClientID %>"))) {
            $isValid = false;
            flagInput($("#<%= cResetLoginName.ClientID %>").parent(), $fillOne_message);
            flagInput($("#<%= cResetUsrEmail.ClientID %>").parent(), $fillOne_message);
        }
        if ($isValid && isNotNullOrEmpty($(".input #<%= cResetUsrEmail.ClientID %>")) && !validateEmailFormat($(".input #<%= cResetUsrEmail.ClientID%>").val())) {
            $isValid = false;
            flagInput($("#<%= cResetUsrEmail.ClientID%>").parent(), $invalid_email_message);
        }
        if (!$isValid) {
            $(".flag:first").next("input").focus()
            return false;
        }
        return true;
    }

    function UpdPassword(noprompt) {
        if (!isTermChecked()) return false;
        //remove any current flags and red borders
        $(".flag").remove();
        $(".input").each(function () {
            if ($(this).data("originalBorderColor") != undefined) {
                $(this).css("borderColor", $(this).data("originalBorderColor"));
                $(this).removeData()
            }
        });
        var Labels = <%= this.ClientID %>_Labels;

        //validate flag
        $isValid = true;
        $mandatory_message = Labels["RequiredFieldMsg"]; // "* Required Field";
        $password_not_match_message = Labels["PasswordNotMatchMsg"]; //"* Passwords do not match"

        if (!isNotNullOrEmpty($(".input #<%= cNewUsrPassword.ClientID %>"))) {
            $isValid = false;
            flagInput($("#<%= cNewUsrPassword.ClientID %>").parent(), $mandatory_message);
        }
        if (!isNotNullOrEmpty($(".input #<%= cConfirmPwd.ClientID %>"))) {
            $isValid = false;
            flagInput($("#<%= cConfirmPwd.ClientID %>").parent(), $mandatory_message);
        }
        if ($isValid) {
            if ($("#<%= cNewUsrPassword.ClientID %>").val() != $("#<%= cConfirmPwd.ClientID %>").val()) {
                flagInput($("#<%= cNewUsrPassword.ClientID %>").parent(), $password_not_match_message);
                flagInput($("#<%= cConfirmPwd.ClientID %>").parent(), $password_not_match_message);
                $isValid = false;
            }
        }
        if (!$isValid) {
            $(".flag:first").next("input").focus();
            return false;
        }
        var bHardenedLogin = $("#<%= cHardenedLogin.ClientID %>").val() == "Y";
        if (noprompt || bHardenedLogin) return true;
        PromptCurrentPassword(function () {<%= this.Page.ClientScript.GetPostBackEventReference(new PostBackOptions(this.cUpdPwdBtn)) %>; }, null);
        return false;
    }

    function UpdateProfile() {
        //remove any current flags and red borders
        $(".flag").remove();
        $(".input").each(function () {
            if ($(this).data("originalBorderColor") != undefined) {
                $(this).css("borderColor", $(this).data("originalBorderColor"));
                $(this).removeData()
            }
        });

        var Labels = <%= this.ClientID %>_Labels;
        //validate flag
        $isValid = true;
        $mandatory_message = Labels["RequiredFieldMsg"]; // "* Required Field";
        $invalid_email_message = Labels["InvalidEmailMsg"]; // "* Not a valid email";

        if (!isNotNullOrEmpty($(".input #<%= cNewLoginName.ClientID %>"))) {
            $isValid = false;
            flagInput($("#<%= cNewLoginName.ClientID %>").parent(), $mandatory_message);
        }
        if (!isNotNullOrEmpty($(".input #<%= cNewUsrName.ClientID %>"))) {
            $isValid = false;
            flagInput($("#<%= cNewUsrName.ClientID %>").parent(), $mandatory_message);
        }
        if (isNotNullOrEmpty($(".input #<%= cNewUsrEmail.ClientID %>")) && !validateEmailFormat($(".input #<%= cNewUsrEmail.ClientID%>").val())) {
            $isValid = false;
            flagInput($("#<%= cNewUsrEmail.ClientID%>").parent(), $invalid_email_message);
        }


        if (!$isValid) {
            $(".flag:first").next("input").focus()
            return false;
        }
        var bHardenedLogin = $("#<%= cHardenedLogin.ClientID %>").val() == "Y";
        if (bHardenedLogin) return true;
        PromptCurrentPassword(function () {<%= this.Page.ClientScript.GetPostBackEventReference(new PostBackOptions(this.cUpdProfileBtn)) %>; }, null);
        return false;
    }

    function CancelAccount() {
        var fnPostback = function () {<%= this.Page.ClientScript.GetPostBackEventReference(new PostBackOptions(this.cCancelAccountLn)) %>; };
        var x = $('#<%= CancelAccountPanel.ClientID %>').dialog({
            autoOpen: false,
            show: "blind",
            hide: "blind",
            modal: true,
            buttons: {
                'ok': fnPostback,
                'cancel': function () { $(this).dialog('close'); }
            },
            open: function (event, ui) {; }
        }).parent().appendTo("form:first");
        $('#<%= CancelAccountPanel.ClientID %>').dialog('open');
        return false;
    }

    function isNotNullOrEmpty(input) {
        return !($(input).val() == "" || $(input).val() == null)
    }

    function flagInput(element, message) {
        $spacer = 12;
        $width = $(element).width();
        $height = $(element).height() / 2;
        $margin = $spacer + $width;
        if (message != "") {
            $(element).prepend("<div style=\"margin-left:" + $margin + "px;margin-top:-" + $height + "px;\" class=\"flag triangle-right left\">" + message + "</div>");
        }
        if ($(this).data("originalBorderColor") == undefined) {
            $(element).data("originalBorderColor", $(element).css("borderColor"));
        }
        $(element).css("borderColor", "red");
    }

    function validateEmailFormat(email) {
        var emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
        return emailPattern.test(email);
    }

    function scorePassword(pass) {
        var score = 0;
        if (!pass) return score;
        // award every unique letter until 5 repetitions
        var letters = {};
        for (var i = 0; i < pass.length; i++) {
            letters[pass[i]] = (letters[pass[i]] || 0) + 1;
            score += 5.0 / letters[pass[i]];
        }
        // bonus points for mixing it up
        var variations = {
            digits: /\d/.test(pass),
            lower: /[a-z]/.test(pass),
            upper: /[A-Z]/.test(pass),
            nonWords: /\W/.test(pass)
        };
        var variationCount = 0;
        for (var check in variations) {
            variationCount += (variations[check] == true) ? 1 : 0;
        }
        score += (variationCount - 1) * 10;
        if (pass.length >= 8) score += 40;
        else if (pass.length >= 6) score += 20;
        if (score > 100) score = 100;
        return parseInt(score);
    }

    Sys.Application.add_load(function () {
        var Labels = <%= this.ClientID %>_Labels;
        var bar = $("#PasswordStrength").progressbar({
            value: 0
        });
        $("#<%= cNewUsrPassword.ClientID %>").keyup(function (event) {
            var score = scorePassword($(this).val());
            var percentile = 0;
            var color = 'red';
            var scoreTxt = Labels["WeakPasswordMsg"]; // "weak";
            if (score > 80) { scoreTxt = Labels["StrongPasswordMsg"], percentile = 100, color = 'green'; }
            else if (score > 60) { scoreTxt = Labels["GoodPasswordMsg"], percentile = 75, color = 'brown'; }
            else if (score > 30) { scoreTxt = Labels["NormalPasswordMsg"], percentile = 50, color = 'yellow'; }

            $("#PasswordStrength").progressbar("option", "value", percentile);
            //if (scoreTxt=="normal") debugger;
            $('#PasswordStrength > div').css('background', color);
            $("#PasswordStrengthLabel").html(scoreTxt);
        });
    });

    function isTermChecked() {
        var disclaimerCBId = $("#<%= cTermsOfServiceCB.ClientID %>");
        var disclaimerTermId = $("#<%= cTermsOfServiceLink.ClientID %>");
        var flagMsg = 'Please check and agree to the terms of service.';
        var disCon = disclaimerCBId == null || disclaimerCBId.length == 0 || disclaimerCBId.is(':checked');
        if (disCon == true) {
            return true;
        } else {
            flagInput(disclaimerTermId.parent(), flagMsg, disclaimerCBId, null);
        }
        return false;
    }
    Sys.Application.add_load(function () {
        var parentURL = $("#<%= cRedirectParent.ClientID %>").val();
        if (parentURL && parentURL != "") {
            window.top.location.href = parentURL;
        }
        var silentLogin = function () {
            if ($('#<%= cJWTLogin.ClientID %>').length > 0 && IsMobile()) {
                // only on mobile
                try {
                    var appDomainUrl = $('#<%= cAppDomainUrl.ClientID %>').val();
                    var user_handle = getUserHandle(appDomainUrl);
                    var refresh_token = JSON.parse(localStorage[getTokenName(appDomainUrl, "refresh_token")]);
                    if (user_handle && refresh_token) {
                        var lastTry = sessionStorage[user_handle + "login"];
                        var lastRetry = (function () { try { return JSON.parse(lastTry);} catch (e) { return null;}; })();
                        if (!lastTry
//                            || +(lastTry.timestamp || 0) + 60 * 1000 < Date.now()
                            || (lastTry.token || "") !== refresh_token
                            ) {
                            var retry = {
                                token: refresh_token,
                                timestamp: Date.now()
                            };
                            sessionStorage[user_handle + "login"] = JSON.stringify(retry);
                            $('#<%= cJWTToken.ClientID %>').val(refresh_token.refresh_token);
                            $('#<%= cJWTLogin.ClientID %>').click();
                        }
                    }
                }
                catch (e) {
                }
            }
        }
        if (window.requestIdleCallback) {
            requestIdleCallback(function () { setTimeout(silentLogin, 1000); });
        }
        else {
            setTimeout(silentLogin, 1000);
        }        
    });

    function getRegistrationRequestAsync() {
        var request = $("#<%= cRegistrationRequest.ClientID %>").val();
            return new Promise(function (resolve, reject) {
                if (!request) reject("no request json");
                else {
                    try {
                        var x = JSON.parse(request);
                        resolve(transformWebAuthRequest(x));
                    } catch (e) {
                        reject(e);
                    }
                }
            });
        }
    function getAssertionRequestAsync() {
        var request = $("#<%= cAssertionRequest.ClientID %>").val();
        return new Promise(function (resolve, reject) {
            if (!request) reject("no request json");
            else {
                try {
                    var x = JSON.parse(request);
                    resolve(transformWebAuthRequest(x));
                } catch (e) {
                    reject(e);
                }
            }
        });
    }

    function transformWebAuthRequest(request) {
        var b64url = new base64Codec(true);
        request.status = undefined;
        request.errorMessage = undefined;
        request.challenge = coerceToArrayBuffer(request.challenge, 'challenge');
        if (request.user && request.user.id) {
            request.user.id = coerceToArrayBuffer(request.user.id, 'user.id');
        }
        if (request.excludeCredentials && request.excludeCredentials) {
            request.excludeCredentials = (request.excludeCredentials || []).map(function (c, i) {
                c.id = coerceToArrayBuffer(c.id, 'excludeCredentials.' + i + '.id');
                return c;
            });
        }
        if (request.allowCredentials && request.allowCredentials) {
            request.allowCredentials = (request.allowCredentials || []).map(function (c, i) {
                c.id = coerceToArrayBuffer(c.id, 'allowCredentials.' + i + '.id');
                return c;
            });
        }
        if (request.authenticatorSelection && !request.authenticatorSelection.authenticatorAttachment) {
            request.authenticatorSelection.authenticatorAttachment = undefined;
        }
        return request;
    }

    var registeredFido2 = null;
    function LoginWebAuthn() {
        var b64url = new base64Codec(true);
        var loginRequest = null;
        var isSafari = navigator.userAgent.match(/Safari/) && true;
        try {
            registeredFido2 = localStorage["Fido2Login"] || "none";
        }
        catch (e) {

        }
        var fnOK = function () {
            <%= this.Page.ClientScript.GetPostBackEventReference(new PostBackOptions(this.cWebAuthnLoginBtn)) %>;
        }

        getAssertionRequestAsync()
        .then(function (request) {
            loginRequest = request;
            if ((!request.allowCredentials || request.allowCredentials.length == 0) && registeredFido2 != "none" && IsMobile()) {
                request.allowCredentials = [
                    {
                        id: b64url.decode(registeredFido2),
                        type: "public-key",
                            // iOS Safari cannot specify Transport
                        transports: isSafari ? undefined : ["ble", "internal", "lightning", "nfc", "usb"],
                    },
                ];
            }
            return navigator.credentials.get({
                publicKey: request
            });
        }
        )
        .then(function (rawAssertion) {
            var id = rawAssertion.id; // id during registration b64url
            var assertion = {
                id: rawAssertion.id,
                rawId: b64url.encode(rawAssertion.rawId),
                type: rawAssertion.type,
                extensions: rawAssertion.getClientExtensionResults(),
                response: {
                    clientDataJSON: b64url.encode(rawAssertion.response.clientDataJSON),
                    userHandle: rawAssertion.response.userHandle && b64url.encode(rawAssertion.response.userHandle) ? b64url.encode(rawAssertion.response.userHandle) : null,
                    signature: b64url.encode(rawAssertion.response.signature),
                    authenticatorData: b64url.encode(rawAssertion.response.authenticatorData)
                }
            };
            var assertionJSON = JSON.stringify(assertion);
            $("#<%= cWebAuthnResult.ClientID %>").val(assertionJSON);
            fnOK();
        })
        .catch(function (err) {
            console.log(err);
            if (
                err.name == "NotAllowedError" // user denied OR another active prompt by another process(firefox/chrome)
                ||
                err.name == "UnknownError" // Legacy Edge when another active prompt by another process 
                ||
                err.name == "NotSupportedError" // Legacy Edge when another active prompt by another process 
                ) {
                if (err.name == "NotSupportedError"
                    &&
                    loginRequest.allowCredentials.length == 0) {
                    alert(err);
                }
                else {
                    alert(err);
                }
            }
        })

        return false;
    }

    function RegisterWebAuthn() {
        var b64url = new base64Codec(true);

        var fnOK = function () {
            <%= this.Page.ClientScript.GetPostBackEventReference(new PostBackOptions(this.cLinkWebAuthnBtn)) %>;
        }
        getRegistrationRequestAsync()
          .then(function (request) {
              return navigator.credentials.create({
                  publicKey: request
              })
          })
          .then(function (newCredentialInfo) {
              var extensions = newCredentialInfo.getClientExtensionResults();
              var result = {
                  Id: newCredentialInfo.id,
                  RawId: b64url.encode(newCredentialInfo.rawId),
                  Type: newCredentialInfo.type,
                  Response: {
                      AttestationObject: b64url.encode(newCredentialInfo.response.attestationObject),
                      ClientDataJson: b64url.encode(newCredentialInfo.response.clientDataJSON),
                  },
                  Extensions: extensions,
                  attestationObject: b64url.encode(newCredentialInfo.response.attestationObject),
                  platform: navigator.platform,
                  isMobile: IsMobile(),
              };
              var resultJSON = JSON.stringify(result);
              localStorage["Fido2Login"] = newCredentialInfo.id;
              $("#<%= cWebAuthnResult.ClientID %>").val(resultJSON);
              fnOK();
      }).catch(function (err) {
          alert(err);
          // No acceptable authenticator or user refused consent. Handle appropriately.
      });
        return false;
    }

    function LoginEth1Wallet(walletconnect) {
        var assertionRequest = $("#<%= cEth1AssertionRequest.ClientID %>").val();
        var fnOK = function () {
            <%= this.Page.ClientScript.GetPostBackEventReference(new PostBackOptions(this.cEth1WalletLoginBtn)) %>;
        };

        var web3 = null;
        var provider = null;
        connectWeb3(undefined, walletconnect)
            .then(function (_web3) {
                web3 = _web3.web3;
                provider = _web3.provider;
                return web3.eth.getAccounts();
            })
            .then(function (accounts) {
                console.log(accounts);
                if (accounts && accounts.length > 0) {
                    return web3.eth.personal.sign(assertionRequest, accounts[0]);
                }
            })
            .then(function (sig) {
                console.log(sig);
                if (sig) {
                    $("#<%= cWebAuthnResult.ClientID %>").val(sig);
                    if (provider.disconnect) {
                        provider.disconnect();
                    }
                    fnOK();
                    return web3.eth.personal.ecRecover(assertionRequest, sig);
                }
            })
            .then(function (addr) {
                console.log(addr);
            })
            .catch(function (e) {
                console.log(e);
            });
        return false;
    }

    function RegisterEth1Wallet(walletconnect) {
        var registrationRequest = $("#<%= cEth1RegistrationRequest.ClientID %>").val();
        var fnOK = function () {
            <%= this.Page.ClientScript.GetPostBackEventReference(new PostBackOptions(this.cLinkEth1WalletBtn)) %>;
        };

        var web3 = null;
        var provider = null;
        connectWeb3(walletconnect)
            .then(function (_web3) {
                web3 = _web3.web3;
                provider = _web3.provider;
                return web3.eth.getAccounts();
            })
            .then(function (accounts) {
                console.log(accounts);
                if (accounts && accounts.length > 0) {
                    return web3.eth.personal.sign(registrationRequest, accounts[0]);
                }
            })
            .then(function (sig) {
                console.log(sig);
                if (sig) {
                    $("#<%= cWebAuthnResult.ClientID %>").val(sig);
                    if (provider.disconnect) {
                        provider.disconnect();
                    }
                    fnOK();
                    return web3.eth.personal.ecRecover(registrationRequest, sig);
                }
            })
            .then(function (addr) {
                console.log(addr);
            })
            .catch(function (e) {
                console.log(e);
            });
        return false;
    }

    Sys.Application.add_load(function () {
        var credentialsContainer = typeof navigator != 'undefined' && navigator.credentials;
        var fido2 = credentialsContainer && typeof window != 'undefined' && window.PublicKeyCredential;
        var rpDomain = $("#<%= cRPDomain.ClientID %>").val();
        var rpName = $("#<%= cRPName.ClientID %>").val();
        if (fido2) {
            var registrationRequest = $("#<%= cRegistrationRequest.ClientID %>").val();
            var assertionRequest = $("#<%= cAssertionRequest.ClientID %>").val();
            if (registrationRequest) {
                $("#<%= cLinkWebAuthnBtn.ClientID %>").show();
            }
            if (assertionRequest) {
                $("#<%= cWebAuthnLoginBtn.ClientID %>").show();
            }
        }
    });

    $(document).ready(function () {
        var hasEthereum = typeof window.ethereum !== "undefined";
        var hasWalletConnect = typeof window.WalletConnectProvider !== "defined";
        var hasWeb3 = typeof window.Web3 !== "undefined" && Web3.version;
        if ((hasEthereum || hasWalletConnect) && hasWeb3) {
            var registrationRequest = $("#<%= cEth1RegistrationRequest.ClientID %>").val();
            var assertionRequest = $("#<%= cEth1AssertionRequest.ClientID %>").val();
            if (registrationRequest) {
                if (hasEthereum) $("#<%= cLinkEth1WalletBtn.ClientID %>").show();
                if (hasWalletConnect) $("#<%= cLinkEth1WalletBtn.ClientID %>").show();
            }
            if (assertionRequest) {
                if (hasEthereum) $("#<%= cEth1WalletLoginBtn.ClientID %>").show();
                if (hasWalletConnect) $("#<%= cMetaMaskLoginBtn.ClientID %>").show();
            }
        }
    });
</script>
<div class="r-table MyPrfContent">
    <div class="r-tr">
        <div class="r-td">
            <div class="ContentTop">
                <div class="login-img">
                    <asp:Image ID="cLoginImage" runat="server" />
                </div>
                <div class="r-table">
                    <div class="r-tr">
                        <div class="r-td">
                            <asp:HyperLink ID="cHome" Visible="false" runat="server">
                                <asp:Image ID="HomeImage" CssClass="link-home" ImageUrl="~/images/home.png" runat="server" />
                            </asp:HyperLink>
                        </div>
                        <div class="r-td">
                            <rcasp:ComboBox ID="cLang" CssClass="inp-ddl" Mode="A" AutoPostBack="true" OnPostBack="cbPostBack" OnSearch="cbCultureId1" DataValueField="CultureTypeId" DataTextField="CultureTypeLabel" OnSelectedIndexChanged="cLang_SelectedIndexChanged" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
            <asp:TextBox ID="cGoogleAccessToken" Style="display: none;" runat="server" Visible="false" />
            <asp:Button ID="cGoogleLoginBtn" Style="display: none;" OnClick="GoogleLoginBtn_Click" runat="server" Visible="false" />
            <asp:TextBox ID="cFacebookAccessToken" Style="display: none;" runat="server" Visible="false" />
            <asp:Button ID="cFacebookLoginBtn" Style="display: none;" OnClick="FacebookLoginBtn_Click" runat="server" Visible="false" />
            <asp:TextBox ID="cAppDomainUrl" Style="display: none;" runat="server" Visible="true" />
            <asp:TextBox ID="cJWTToken" Style="display: none;" runat="server" Visible="true" />
            <asp:Button ID="cJWTLogin" Style="display: none;" runat="server" Visible="true" />
            <asp:TextBox ID="cServerChallenge" runat="server" Visible="true" style="display:none;" />
            <asp:TextBox ID="cRPDomain" runat="server" Visible="true" style="display:none;" />
            <asp:TextBox ID="cRPName" runat="server" Visible="true" style="display:none;" />
            <asp:TextBox ID="cWebAuthnResult" runat="server" Visible="true" style="display:none;" />
            <asp:TextBox ID="cRegistrationRequest" runat="server" Visible="true" style="display:none;" />
            <asp:TextBox ID="cAssertionRequest" runat="server" Visible="true" style="display:none;" />
            <asp:TextBox ID="cEth1RegistrationRequest" runat="server" Visible="true" style="display:none;" />
            <asp:TextBox ID="cEth1AssertionRequest" runat="server" Visible="true" style="display:none;" />
            <asp:TextBox ID="cMyMachine" runat="server" style="display:none;" />
            <asp:TextBox ID="cMyAppSig" runat="server" style="display:none;" />
            <asp:TextBox ID="cFCMToken" runat="server" style="display:none;" />

            <asp:Panel ID="LoginPanel" CssClass="pNewPwd" DefaultButton="cLoginBtn" runat="server">
                <div class="title-content">
                    <div>
                        <img src="images/lock.png" />
                    </div>
                    <div class="titleLogin">
                        <h2>
                            <asp:Label ID="LoginAreaTitle" runat="server" /></h2>
                    </div>
                </div>
                <div>
                    <asp:Label ID="cLoginNameLabel" CssClass="inp-lbl" runat="server" />
                </div>
                <div class="input">
                    <asp:TextBox ID="cLoginName" CssClass="inp-txt" runat="server" />
                </div>
                <div>
                    <asp:Label ID="cUsrPasswordLabel" CssClass="inp-lbl" runat="server" />
                </div>
                <div class="input">
                    <asp:TextBox ID="cUsrPassword" CssClass="inp-txt" TextMode="Password" runat="server" />
                </div>
                <div id="EnableNotificationPanel" style="display:none;">
                    <asp:CheckBox ID="cEnableNotification" Text="Enable Push Notification" CssClass="inp-txt" onclick="enableNotification(event);" runat="server" />
                </div>
                <asp:Panel ID="LoginMathPanel" Visible="false" runat="server">
                    <div>
                        <asp:Label ID="cLoginHumanLabel" CssClass="inp-lbl" runat="server" />
                    </div>
                    <div class="input">
                        <asp:Label ID="lit_math_plusminus" CssClass="inp-lbl" runat="server" />=
                        <asp:TextBox ID="cMathAnswer" CssClass="inp-txt" runat="server" />
                        <asp:TextBox ID="cMathExpectedAnswer" Visible="false" runat="server" />
                        <asp:TextBox ID="cLoginAttempts" Visible="false" Text="0" runat="server" />
                    </div>
                </asp:Panel>
                <div>
                    <asp:LinkButton ID="cForgetBtn" Style="color: #1155cc;" OnClick="ForgetBtn_Click" runat="server" />
                </div>
                <div class="LoginButton">
                    <asp:Button ID="cLoginBtn" OnClientClick="return Login();" OnClick="LoginBtn_Click" CssClass="btn_login" runat="server" />
                </div>
                <div class="LoginButton">
                    <asp:Button ID="cWebAuthnLoginBtn" Style="display: none;" Text="WebAuthn(Fido2) Passwordless Login" OnClientClick="return LoginWebAuthn();" OnClick="WebAuthnLoginBtn_Click" CssClass="btn_login" runat="server" />
                </div>
                <div class="LoginButton">
                    <asp:Button ID="cMetaMaskLoginBtn" Style="display: none;" Text="MetaMask Passwordless Login" OnClientClick="return LoginEth1Wallet(false);" OnClick="Eth1WalletLoginBtn_Click" CssClass="btn_login" runat="server" />
                </div>
                <div class="LoginButton">
                    <asp:Button ID="cEth1WalletLoginBtn" Style="display: none;" Text="Eth1 Mobile Wallet Passwordless Login" OnClientClick="return LoginEth1Wallet(true);" OnClick="Eth1WalletLoginBtn_Click" CssClass="btn_login" runat="server" />
                </div>
                <asp:Panel ID="separatePanel" Visible="false" runat="server">
                    <div class="separateLine"></div>
                    <div class="middleText">
                        <asp:Label Text="or" runat="server" />
                    </div>
                    <div class="separateLine"></div>
                    <div style="clear: both;"></div>
                </asp:Panel>
                <div>
                    <asp:Panel ID="WindowsLoginPanel" Visible="false" CssClass="WinSignInPanel" runat="server">
                        <asp:Image ID="Image1" ImageUrl="~/images/window-login.png" CssClass="signInImg" runat="server" />
                        <asp:Button ID="cWindowsLoginBtn" CssClass="signInBtn" Text="Sign in with Windows" OnClick="WindowsLoginBtn_Click" runat="server" />
                    </asp:Panel>
                    <asp:Panel ID="Office365LoginPanel" Visible="false" CssClass="OffSignInPanel" runat="server">
                        <asp:Image ID="Image2" ImageUrl="~/images/office365-login.png" CssClass="signInImg" runat="server" />
                        <asp:Button ID="cOffice365LoginBtn" CssClass="signInBtn" Text="Sign in with Office365" OnClick="AzureLoginBtn_Click" runat="server" />
                    </asp:Panel>
                    <asp:Panel ID="GoogleLoginPanel" Visible="false" CssClass="GoogleSignInPanel" runat="server">
                        <asp:Image ImageUrl="~/images/google-login.png" CssClass="signInImg" runat="server" />
                        <asp:Button ID="cGoogleSignInBtn" CssClass="signInBtn" Text="Sign in with Google" OnClientClick="return false;" runat="server" />
                    </asp:Panel>
                    <asp:Panel ID="FacebookLoginPanel" Visible="false" CssClass="FbSignInPanel" runat="server">
                        <asp:Image ImageUrl="~/images/facebook-login.png" CssClass="signInImg" runat="server" />
                        <asp:Button ID="cFacebookSignInBtn" CssClass="signInBtn" Text="Sign in with Facebook" OnClientClick="return false;" runat="server" />
                    </asp:Panel>
                    <div style="clear: both;"></div>
                </div>
                <div class="MyAcctWarnMsg">
                    <asp:Label ID="cWarnMsg1" Visible="true" runat="server" /><asp:Label ID="cWarnMsg2" Visible="false" runat="server" />
                </div>
                <div class="MaintMsg">
                    <asp:TextBox ID="cMaintMsg" TextMode="MultiLine" Enabled="false" runat="server" />
                </div>
                <asp:Panel ID="SignUpPanel" Visible="false" CssClass="signInPanel" runat="server">
                    <asp:HyperLink ID="cSignUpUrl" Text="Create an account here" runat="server" />
                </asp:Panel>
            </asp:Panel>
            <asp:Panel ID="OTPPanel" runat="server" Visible="false" DefaultButton="cCodeVerifyBtn">
                <%--new change--%>
                <asp:Label ID="cOTPAccessCodeHelp" runat="server"></asp:Label>
                <div class="accessCodeSec">
                    <div class="r-table">
                        <div class="r-tr">
                            <div class="r-td rc-1-3">
                                <b>
                                    <asp:Label ID="cOTPAccessCodeLabel" runat="server" />:</b>
                            </div>
                            <div class="r-td rc-4-9">
                                <rcasp:OTPTextBox ID="cOTPAccessCode" TimeSkew="10" runat="server" OnTextChanged="cOTPAccessCode_TextChanged"  />
                            </div>
                            <div class="r-td rc-10-12">
                                <asp:Button ID="cCodeVerifyBtn" CssClass="codeVerifyBtn " runat="server" Text="Verify" OnClick="cCodeVerifyBtn_Click" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="accessCodeBtnSec">
                    <asp:Button ID="cSendOTPAccessCodeBtn" runat="server" OnClick="cSendOTPAccessCodeBtn_Click" />
                </div>
                <div class="RememberCodeSec">
                    <asp:CheckBox ID="cRememberOTPAccessCode" runat="server" />
                </div>
                <%--end new change--%>
            </asp:Panel>
            <asp:Panel ID="SelectLoginPanel" Visible="false" CssClass="SelectLoginPanel" runat="server">
                <div class="GoogleLoginTitle">
                    <asp:Label ID="GoogleLoginTitle" runat="server" />
                </div>
                <asp:RadioButtonList ID="cLoginNameChoice" DataValueField="LoginName" DataTextField="LoginName" CssClass="LoginNameSec" runat="server" />
                <div class="GoogleLoginBtnSec">
                    <div>
                        <asp:Button ID="cCancelLoginBtn" CssClass="btn_login" Text="Cancel" OnClick="CancelLoginBtn_Click" runat="server" />
                    </div>
                    <div>
                        <asp:Button ID="cPickLoginBtn" CssClass="btn_login" Text="Continue" OnClick="PickLoginBtn_Click" runat="server" />
                    </div>
                    <div style="clear: both;"></div>
                </div>
                <asp:TextBox ID="cProvider" Visible="false" runat="server" />
                <asp:TextBox ID="cProviderLoginName" Visible="false" runat="server" />
            </asp:Panel>

            <asp:Panel ID="PwdResetPanel" CssClass="pNewPwd" DefaultButton="cResetPwdBtn" runat="server">
                <div>
                    <h2 class="pwdRibbon">
                        <asp:Label ID="RestPwdTitle" runat="server" /></h2>
                </div>
                <div>
                    <asp:Label ID="cResetLoginNameLabel" CssClass="inp-lbl" runat="server" />
                </div>
                <div class="input">
                    <asp:TextBox ID="cResetLoginName" CssClass="inp-txt" runat="server" />
                </div>
                <div>
                    <asp:Label ID="cResetOrLabel" CssClass="inp-lbl" runat="server" />
                </div>
                <br />
                <div>
                    <asp:Label ID="cResetUsrEmailLabel" CssClass="inp-lbl" runat="server" />
                </div>
                <div class="input">
                    <asp:TextBox ID="cResetUsrEmail" CssClass="inp-txt" runat="server" />
                </div>
                <div class="LoginButton">
                    <asp:Button ID="cResetPwdBtn" OnClientClick="return ResetPassword();" CssClass="btn_login" OnClick="ResetPwdBtn_Click" runat="server" />
                </div>
            </asp:Panel>

            <asp:Panel ID="UserProfilePanel" runat="server">
                <asp:TextBox ID="cHardenedLogin" Enabled="false" runat="server" Style="display: none;" />
                <asp:Panel ID="NewPwdPanel" CssClass="pNewPwd" DefaultButton="cUpdPwdBtn" runat="server">
                    <div>
                        <h2>
                            <asp:Label ID="NewPwdTitle" runat="server" /></h2>
                    </div>
                    <div class="r-table">
                        <div class="r-tr">
                            <div class="r-td">
                                <asp:Label ID="cLastPwdChgDtLbl" CssClass="inp-lbl" runat="server" />
                                <asp:Label CssClass="lbPwdInfo" runat="server" ID="cLastPwdChgDt" />
                            </div>
                            <div class="r-td">
                                <asp:Label ID="cPwdExpiryDtLbl" CssClass="inp-lbl" runat="server" />
                                <asp:Label CssClass="lbPwdInfo" runat="server" ID="cPwdExpiryDt" />
                            </div>
                        </div>
                    </div>
                    <div>
                        <asp:Label ID="cPwdExpMsg" runat="server" class="MyAcctWarnMsg" />
                    </div>
                    <div id="PasswordStrength" style="padding: 0 3px; width: 100%; border: none;"><span id="PasswordStrengthLabel" style="position: absolute;"></span></div>
                    <div>
                        <asp:Label ID="cNewUsrPasswordLabel" CssClass="inp-lbl" runat="server" />
                    </div>
                    <div class="input">
                        <asp:TextBox ID="cNewUsrPassword" CssClass="inp-txt" TextMode="Password" runat="server" />
                    </div>
                    <div>
                        <asp:Label ID="cConfirmPwdLabel" CssClass="inp-lbl" runat="server" />
                    </div>
                    <div class="input">
                        <asp:TextBox ID="cConfirmPwd" CssClass="inp-txt" TextMode="Password" runat="server" />
                    </div>
                    <div class="input">
                        <asp:Checkbox ID="cRemoveLinkedLogin" CssClass="inp-txt" Text="Remove all linked ID provider" runat="server" />
                    </div>
                    <div style="color: blue; width: 100%; border-radius: 4px; margin: 2px 0; padding: 5px 0px 0px 0px; font-size: 11px;">
                        <asp:Label ID="cPwdHlpMsgLabel" runat="server" />
                    </div>
                    <asp:Panel ID="TermsPanel" runat="server">
                        <div class="cbTerm">
                            <asp:CheckBox ID="cTermsOfServiceCB" CssClass="cbTermOfService" runat="server" />
                        </div>
                        <div class="cbTerm">
                            <asp:HyperLink ID="cTermsOfServiceLink" CssClass="inp-txtln TermsOfServiceLink" Target="_blank" NavigateUrl="~/home/terms_of_service.pdf" runat="server" />
                        </div>
                    </asp:Panel>
                    <div class="LoginButton">
                        <asp:Button ID="cUpdPwdBtn" OnClientClick="return UpdPassword();" CssClass="btn_login" OnClick="UpdPwdBtn_Click" runat="server" />
                    </div>
                </asp:Panel>
                <asp:Panel ID="ConfirmPwdPanel" Style='display: none;' runat="server">
                    <div>
                        <asp:Label ID="cUsrPasswordVerifyLabel" CssClass="inp-lbl" runat="server" />
                    </div>
                    <div class="input">
                        <asp:TextBox ID="cUsrPasswordVerify" CssClass="inp-txt" TextMode="Password" MaxLength="20" Width="200" runat="server" />
                    </div>
                </asp:Panel>
                <div style="color: Blue; width: 100%; border-radius: 4px; margin: 10px 0; padding: 5px 0px 0px 0px; font-size: 14px;">
                    <asp:Label ID="cMsg" runat="server" />
                </div>
                <%--new change--%>
                <asp:Panel ID="TwoFactorAuthenticationPanel" runat="server">
                    <div class="TwoFactorAuthenticationBtn"><asp:Button ID="cLinkWebAuthnBtn" runat="server" OnClientClick="return RegisterWebAuthn();" Style="display: none;" Text="Register WebAuthn(Fido2) Passwordless Login" OnClick="cLinkWebAuthnBtn_Click" Visible="true" /></div>
                    <div class="TwoFactorAuthenticationBtn"><asp:Button ID="cLinkEth1WalletBtn" runat="server" OnClientClick="return RegisterEth1Wallet(true);" Style="display: none;" Text="Register Eth1 Mobile Wallet Login" OnClick="cLinkEth1WalletBtn_Click" Visible="true" /></div>
                    <div class="TwoFactorAuthenticationBtn"><asp:Button ID="cLinkMetaMaskBtn" runat="server" OnClientClick="return RegisterEth1Wallet(false);" Style="display: none;" Text="Register MetaMask Login" OnClick="cLinkEth1WalletBtn_Click" Visible="true" /></div>
                    <div class="TwoFactorAuthenticationBtn"><asp:Button ID="cForgetOTPCache" runat="server" OnClick="cForgetOTPCache_Click" Visible="true" /></div>
                    <div class="TwoFactorAuthenticationBtn"><asp:Button ID="cDisableTwoFactor" runat="server" OnClick="cDisableTwoFactor_Click" Visible="true" /></div>
                    <div class="TwoFactorAuthenticationBtn"><asp:Button ID="cResetTwoFactorKey" runat="server" OnClick="cResetTwoFactorKey_Click" Visible="true" /></div>
                    <div class="TwoFactorAuthenticationBtn"><asp:Button ID="cShowTwoFactorKey" runat="server" OnClick="cShowTwoFactorKey_Click" Visible="true" /></div>
                    <asp:CheckBox ID="cChangeTwoFactoryKey" runat="server" Visible="false" />
                    <asp:Panel ID="TwoFactorSecretPanel" CssClass="TwoFactorSecretPanel" runat="server"  Visible="false">
                        <div>
                            <asp:Label ID="cTwoFactorSecretKeyHelp" runat="server"></asp:Label>
                        </div>
                        <div>
                            <asp:Image ID="cTwoFactorSecretQRCode" runat="server" />
                        </div>
                        <div>
                            <b><asp:Label ID="cTwoFactorSecretKeyLabel" runat="server" />:</b>
                        </div>
                        <div>
                            <asp:Label ID="cTwoFactorSecretKey" runat="server" Enabled="false" />
                        </div>
                        
                    </asp:Panel>
                    <asp:Panel ID="TwoFactorSecretCodePanel" runat="server"  Visible="false" DefaultButton="cSecretCodeBtn">
                        <div class="SecretCodeLabel">
                            <asp:Label ID="cTwoFactorSecretCodeHelp" runat="server"></asp:Label>
                        </div>
                        <div class="accessCodeSec">
                            <div class="r-table">
                                <div class="r-tr">
                                    <div class="r-td rc-1-3">
                                        <b>
                                            <asp:Label ID="cTwoFactorSecretCodeLabel" runat="server" />:</b>
                                    </div>
                                    <div class="r-td rc-4-9">
                                        <rcasp:OTPTextBox ID="cTwoFactorSecretCode" runat="server" OnTextChanged="cTwoFactorSecretCode_TextChanged" />
                                    </div>
                                    <div class="r-td rc-10-12">
                                        <asp:Button ID="cSecretCodeBtn" CssClass="codeVerifyBtn " runat="server" Text="Verify" OnClick="cCodeVerifyBtn_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>
                </asp:Panel>
                <%--end new change--%>
                <div>
                    <asp:Panel ID="cLinkWindowsPanel" Visible="false" CssClass="WinLinkPanel" runat="server">
                        <asp:Image ID="Image3" ImageUrl="~/images/window-login.png" CssClass="signInImg" runat="server" />
                        <asp:Button ID="cLinkWindowsBtn" CssClass="signInBtn" runat="server" Text="Link Windows" OnClick="cLinkWindowsBtn_Click" Visible="true" />
                    </asp:Panel>
                    <asp:Panel ID="cLinkMicrosoftPanel" Visible="false" CssClass="OffLinkPanel" runat="server">
                        <asp:Image ID="Image4" ImageUrl="~/images/office365-login.png" CssClass="signInImg" runat="server" />
                        <asp:Button ID="cLinkMicrosoftBtn" CssClass="signInBtn" runat="server" Text="Link Microsoft" OnClick="cLinkMicrosoftBtn_Click" Visible="true" />
                    </asp:Panel>
                    <asp:Panel ID="cLinkGooglePanel" Visible="false" CssClass="GoogleLinkPanel" runat="server">
                        <asp:Image ID="Image5" ImageUrl="~/images/google-login.png" CssClass="signInImg" runat="server" />
                        <asp:Button ID="cLinkGoogleBtn" CssClass="signInBtn" runat="server" Text="Link Google"  OnClick="cLinkGoogleBtn_Click" Visible="true" />
                    </asp:Panel>
                    <asp:Panel ID="cLinkFacebookPanel" Visible="false" CssClass="FbLinkPanel" runat="server">
                        <asp:Image ID="Image6" ImageUrl="~/images/facebook-login.png" CssClass="signInImg" runat="server" />
                        <asp:Button ID="cLinkFacebookBtn" CssClass="signInBtn" runat="server" Text="Link Facebook" OnClick="cLinkFacebookBtn_Click" Visible="true" />
                    </asp:Panel>
                    <div style="clear: both;"></div>
                </div>

                <asp:Panel ID="LinkSSOPanel" CssClass="pNewProfile" runat="server">
                </asp:Panel>
                <asp:Panel ID="NewProfilePanel" CssClass="pNewProfile" DefaultButton="cUpdProfileBtn" runat="server">
                    <div>
                        <h2>
                            <asp:Label ID="PwdTitle" runat="server" /></h2>
                    </div>
                    <div class="r-table">
                        <div class="r-tr">
                            <div class="r-td">
                                <asp:Panel ID="cPicMedPan" CssClass="DocPanel" Visible="false" runat="server">
                                    <div class="r-table">
                                        <div class="r-tr">
                                            <div class="r-td">
                                                <asp:FileUpload ID="cPicMedFi" runat="server" />
                                            </div>
                                            <div class="r-td">
                                                <asp:Button ID="cPicMedUpl" CssClass="small blue button" OnClick="cPicMedUpl_Click" Text="Upload" runat="server" />
                                            </div>
                                        </div>
                                    </div>
                                </asp:Panel>
                                <asp:ImageButton ID="cPicMed" Height="50" ToolTip="Click the icon on the right to upload your most recent picture/icon to represent you on applicable screens." runat="server" />
                                <asp:ImageButton ID="cPicMedTgo" OnClick="cPicMedTgo_Click" CssClass="r-icon" ImageUrl="~/Images/UpLoad.png" CausesValidation="false" runat="server" />
                            </div>
                        </div>
                    </div>
                    <div>
                        <asp:Label ID="cNewLoginNameLabel" CssClass="inp-lbl" runat="server" />
                    </div>
                    <div class="input">
                        <asp:TextBox ID="cNewLoginName" CssClass="inp-txt" runat="server" />
                    </div>
                    <div>
                        <asp:Label ID="cNewUserNameLabel" CssClass="inp-lbl" runat="server" />
                    </div>
                    <div class="input">
                        <asp:TextBox ID="cNewUsrName" CssClass="inp-txt" runat="server" />
                    </div>
                    <div>
                        <asp:Label ID="cNewUsrEmailLabel" CssClass="inp-lbl" runat="server" />
                    </div>
                    <div class="input">
                        <asp:TextBox ID="cNewUsrEmail" CssClass="inp-txt" runat="server" />
                    </div>
                    <div class="LoginButton">
                        <asp:LinkButton ID="cCancelAccountLn" Visible="false" OnClick="cCancelAccount_Click" OnClientClick="return CancelAccount();" Text="Cancel Account" runat="server"></asp:LinkButton>
                        <asp:Button ID="cUpdProfileBtn" OnClientClick="return UpdateProfile();" CssClass="btn_login" OnClick="UpdateProfileBtn_Click" runat="server" />
                    </div>
                    <asp:Panel ID="CancelAccountPanel" Style='display: none;' runat="server">
                        <div>
                            <asp:Label ID="cCancelAccountMsg" Text="test" runat="server" />
                        </div>
                    </asp:Panel>
                </asp:Panel>
            </asp:Panel>
        </div>
    </div>
</div>
<div class="r-table">
    <div class="r-tr">
        <div class="rc-1-12" id="cMsgDiv" visible="false" runat="server">
            <div>
                <div>
                    <asp:Label ID="cMsgContent" Style="display: none;" EnableViewState="false" runat="server" />
                </div>
            </div>
        </div>
        <asp:HiddenField ID="cRedirectParent" runat="server" />
    </div>
</div>
