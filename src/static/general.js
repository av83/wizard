function validate(rules) {
    var result = true;

    for (i = 0; i < rules.length; ++i) {
        input = $('input[name="' + rules[i].name + '"]');

        input.next().remove();

        if (!rules[i].expression.test(input.val())) {
            result = false;
            input.after('<span class="validationError">' + rules[i].message + '</span>');
        }
    }

    return result;
}


function setThisHomePage()
{
    try
    {
        if (document.all && !window.opera)
        {
            this.style.behavior='url(#default#homepage)';
            this.setHomePage(this.href);
        }
        else
        {
            if (window.netscape && window.netscape.security)
            {
                netscape.security.PrivilegeManager.enablePrivilege('UniversalPreferencesRead');
                if (navigator.preference('browser.startup.homepage') != this.url)
                {
                    navigator.security.PrivilegeManager.enablePrivilege('UniversalPrefrencesWrite');
                    navigator.preference('browser.startup.homepage', this.url);
                }
            }
        }
    }
    catch(e){alert(e.message);}
}
