function [train_pred, test_pred] = predict_cnn(training_set, training_labels, testing_set)

    image_width = sqrt(size(training_set,2));
    training_set = reshape(training_set', image_width, image_width, 1, size(training_set,1));
    testing_set = reshape(testing_set', image_width, image_width, 1, size(testing_set,1));
    
    layers = [ ...
        imageInputLayer([28 28 1])
        convolution2dLayer(5, 6, 'Padding', 'same')
        tanhLayer
        averagePooling2dLayer(2, 'Stride', 2)
        convolution2dLayer(5,16)
        tanhLayer
        averagePooling2dLayer(2, 'Stride', 2)
        convolution2dLayer(5,120)
        tanhLayer
        fullyConnectedLayer(84)
        fullyConnectedLayer(2)
        softmaxLayer
        classificationLayer ];
    
    options = trainingOptions('sgdm','InitialLearnRate',0.001);

    net = trainNetwork(training_set, categorical(training_labels), layers, options);

    train_pred = predict(net, training_set);
    train_pred = (vec2ind(train_pred') - 1)';

    test_pred = predict(net, testing_set);
    test_pred = (vec2ind(test_pred') - 1)';
    
end