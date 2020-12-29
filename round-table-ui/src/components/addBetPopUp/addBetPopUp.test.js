import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import AddBetPopUp from './addBetPopUp';

describe('<AddBetPopUp />', () => {
  test('it should mount', () => {
    render(<AddBetPopUp />);
    
    const addBetPopUp = screen.getByTestId('AddBetPopUp');

    expect(addBetPopUp).toBeInTheDocument();
  });
});