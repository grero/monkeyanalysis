function tests = monkeytests
    tests = functiontests(localfunctions);
end

function testStrobesToWords1(testCase)
    w1 = strobesToWords(-64);
    w0 = [1 1 0 0 0 0 0 0];
    verifyEqual(testCase,w0,w1)
end

function testStrobesToWords2(testCase)
    w1 = strobesToWords(4415);
    w0 = [1 1 0 0 0 0 0 0];
    verifyEqual(testCase,w0,w1)
end

function testStrobesToWords3(testCase)
    w1 = strobesToWords(4159);
    w0 = [1 1 0 0 0 0 0 0];
    verifyEqual(testCase,w0,w1)
end

function testStrobesToWords4(testCase)
    w1 = strobesToWords(-4416);
    w0 = [1 1 0 0 0 0 0 0];
    verifyEqual(testCase,w0,w1)
end

function testStrobesToWords5(testCase)
    w1 = strobesToWords(4606);
    w0 = [0 0 0 0 0 0 0 1];
    verifyEqual(testCase,w0,w1)
end
