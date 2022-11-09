const tempProgress = (function () {
    const key = 'gibctProgress';
    return {
        reload: function () {
            location.reload();
        },
        timeout: function (){
            setTimeout("location.reload();",10000);
        },
        read: function () {
            return window.localStorage.getItem(key);
        },
        write: function (value) {
            window.localStorage.setItem(key,value);
        },
        reset: function () {
            window.localStorage.clear();
        },
        exist: function () {
            const data = tempProgress.read();
            return data !== undefined;
        },
        isCompleteOrHasError: function () {
            const data = tempProgress.read();
            return (data.startsWith('Complete') || data.startsWith('There was an error'));
        },
    }
})();
